import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:moengage_task/model/internal/sort_mode.dart';
import 'package:moengage_task/model/response/articles_response.dart';
import 'package:moengage_task/util/extensions.dart';
import 'package:moengage_task/util/helpers.dart';
import 'package:moengage_task/util/services.dart';
import 'package:moengage_task/util/states.dart';
import 'package:moengage_task/widget/article_item.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../model/common/article.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // state holder for articles received from API
  final _onlineArticlesIN = RM.inject<List<Article>>(() => []);

  // state holder for articles stored offline
  final _offlineArticlesIN = RM.inject<List<Article>>(() => articlesBox.values.toList());

  // state holder for final filtered articles to be displayed
  final _filteredArticlesIN = RM.inject<List<Article>>(() => []);

  final _searchController = TextEditingController();

  // state holder for search text
  final _searchTextIN = RM.inject(() => "");

  // state holder representing live connectivity status as boolean (offline mode)
  final _offlineModeIN = RM.inject(() => false);

  // state holder for currently selected sort mode
  final _sortModeIN = RM.inject(() => SortMode.latestFirst);

  // stream subscription to listen to connectivity changes
  // stored in a variable such that we can dispose it when the app closes and avoid memory leaks
  late StreamSubscription _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    // initialise the connectivity listener
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((event) {
      // update state holder
      _offlineModeIN.setState((s) => s = event == ConnectivityResult.none);
      // reset search text
      _searchController.text = "";
      _searchTextIN.refresh();

      // update data to be shown based on connectivity status
      if (_offlineModeIN.state) {
        // show offline data
        _updateFilteredList();
        _showOfflineModeSnackBar();
      } else {
        // refresh articles list from api and display accordingly
        _loadArticles();
      }
    });
  }

  @override
  void dispose() {
    // properly dispose the listener to avoid memory leaks
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MoEngage Articles")),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: OnBuilder(
          sideEffects: SideEffects(
            initState: () async {
              // initialise data and connectivity status
              final isOnline = await Connectivity().checkConnectivity() != ConnectivityResult.none;
              _offlineModeIN.setState((s) => s = !isOnline);
              if (isOnline) {
                _loadArticles();
              } else {
                _updateFilteredList();
              }
            },
          ),
          listenToMany: [_filteredArticlesIN, _onlineArticlesIN, _offlineArticlesIN, _searchTextIN, _offlineModeIN, _sortModeIN],
          builder: () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Visibility(
                      // show only in offline mode
                      // an indicator to remind the user that connectivity is unavailable
                      visible: _offlineModeIN.state,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: IconButton(onPressed: () => _showOfflineModeSnackBar(), icon: const Icon(Icons.wifi_off)),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        // the search text field
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (newSearchText) {
                          // update the articles list when user clicks search button in keyboard
                          _searchTextIN.setState((s) => s = newSearchText);
                          _updateFilteredList();
                        },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          // clear text button will only be visible when search text is not empty
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchTextIN.refresh();
                                    _searchController.text = "";
                                    _updateFilteredList();
                                  },
                                )
                              : null,
                          label: const Text("Search"),
                          hintText: "by publishers, authors, title",
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(Icons.sort),
                        // sort mode dropdown
                        DropdownButton<SortMode>(
                          value: _sortModeIN.state,
                          items: SortMode.values.map((e) => DropdownMenuItem(value: e, child: Text(e.toString().split(".")[1].readableFromCamelCase))).toList(),
                          onChanged: (newSortMode) {
                            if (newSortMode != null) {
                              // update sort mode state and refresh data according to new sort mode state
                              _sortModeIN.setState((s) => s = newSortMode);
                              _updateFilteredList();
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: !_offlineModeIN.state && _onlineArticlesIN.isWaiting
                    ? centeredProgress // show progress bar when loading articles from API
                    : _onlineArticlesIN.hasError
                        ? Center(
                            // show error message in case of issue from API
                            child: Text(_onlineArticlesIN.error.message),
                          )
                        : _filteredArticlesIN.state.isEmpty
                            ? const Center(
                                // helper text
                                child: Text("No articles found"),
                              )
                            : ListView.builder(
                                itemCount: _filteredArticlesIN.state.length,
                                itemBuilder: (context, index) {
                                  final _article = _filteredArticlesIN.state[index];
                                  // using url as unique field for articles since we are not getting id
                                  // check whether offline db has article with same url
                                  // if offline db has this article, offlineIndex will be >= 0
                                  final offlineIndex = _offlineArticlesIN.state.indexWhere((element) => element.url == _article.url);
                                  return ArticleItem(
                                    article: _article,
                                    isOffline: offlineIndex >= 0,
                                    onOfflineActionPress: (newOffline) {
                                      if (newOffline) {
                                        // save article
                                        articlesBox.add(_article);
                                        showSnackBar(context, content: "Saved offline");
                                      } else {
                                        // delete article
                                        articlesBox.deleteAt(offlineIndex);
                                        showSnackBar(context, content: "Deleted");
                                      }
                                      articlesBox.flush();
                                      _offlineArticlesIN.refresh();
                                      _updateFilteredList();
                                    },
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadArticles() {
    _onlineArticlesIN.setState((s) async {
      final articlesResp = await articlesService.getArticles();
      if (articlesResp.success && articlesResp.data != null && articlesResp.data!.status == ResponseStatus.ok && articlesResp.data!.articles != null) {
        // update filtered articles
        _filteredArticlesIN.setState((s) => s = articlesResp.data!.articles!);
        return s = articlesResp.data!.articles!;
      } else {
        throw Exception(articlesResp.errorTitle + "\n" + articlesResp.errorMessage);
      }
    });
  }

  void _showOfflineModeSnackBar() => showSnackBar(context, content: "Viewing in offline mode");

  void _updateFilteredList() {
    final _loweredSearchText = _searchTextIN.state.toLowerCase();
    _filteredArticlesIN.setState((s) {
      s.clear();
      // check if search text is empty
      if (_loweredSearchText.isNotEmpty) {
        // apply filters when search text is not empty
        // search by title/publisher (sourceName)/author
        s.addAll((_offlineModeIN.state ? _offlineArticlesIN : _onlineArticlesIN).state.where(
              (element) =>
                  element.title.toLowerCase().contains(_loweredSearchText) ||
                  (element.author != null && element.author!.toLowerCase().contains(_loweredSearchText)) ||
                  (element.source != null && element.source!.name.toLowerCase().contains(_loweredSearchText)),
            ));
      } else {
        // add all data if search text is empty
        s.addAll((_offlineModeIN.state ? _offlineArticlesIN : _onlineArticlesIN).state);
      }
      s.sort((a1, a2) {
        // sort the articles by published time
        if (_sortModeIN.state == SortMode.oldestFirst) {
          return a1.publishedAt!.compareTo(a2.publishedAt!);
        } else {
          return a2.publishedAt!.compareTo(a1.publishedAt!);
        }
      });
    });
  }
}
