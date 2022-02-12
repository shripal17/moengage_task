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
  final _onlineArticlesIN = RM.inject<List<Article>>(() => []);
  final _offlineArticlesIN = RM.inject<List<Article>>(() => articlesBox.values.toList());
  final _filteredArticlesIN = RM.inject<List<Article>>(() => []);

  final _searchController = TextEditingController();
  final _searchTextIN = RM.inject(() => "");

  final _offlineModeIN = RM.inject(() => false);
  final _sortModeIN = RM.inject(() => SortMode.latestFirst);

  late StreamSubscription _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((event) {
      _offlineModeIN.setState((s) => s = event == ConnectivityResult.none);
      _searchController.text = "";
      _searchTextIN.refresh();
      if (_offlineModeIN.state) {
        _updateFilteredList();
        _showOfflineModeSnackBar();
      } else {
        _loadArticles();
      }
    });
  }

  @override
  void dispose() {
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
                      visible: _offlineModeIN.state,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: IconButton(onPressed: () => _showOfflineModeSnackBar(), icon: const Icon(Icons.wifi_off)),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (newSearchText) {
                          _searchTextIN.setState((s) => s = newSearchText);
                          _updateFilteredList();
                        },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
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
                        DropdownButton<SortMode>(
                          value: _sortModeIN.state,
                          items: SortMode.values.map((e) => DropdownMenuItem(value: e, child: Text(e.toString().split(".")[1].readableFromCamelCase))).toList(),
                          onChanged: (newSortMode) {
                            if (newSortMode != null) {
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
                    ? centeredProgress
                    : _onlineArticlesIN.hasError
                        ? Center(
                            child: Text(_onlineArticlesIN.error.message),
                          )
                        : _filteredArticlesIN.state.isEmpty
                            ? const Center(
                                child: Text("No articles found"),
                              )
                            : ListView.builder(
                                itemCount: _filteredArticlesIN.state.length,
                                itemBuilder: (context, index) {
                                  final _article = _filteredArticlesIN.state[index];
                                  final offlineIndex = _offlineArticlesIN.state.indexWhere((element) => element.url == _article.url);
                                  return ArticleItem(
                                    article: _article,
                                    isOffline: offlineIndex >= 0,
                                    onOfflineActionPress: (newOffline) {
                                      if (newOffline) {
                                        articlesBox.add(_article);
                                        showSnackBar(context, content: "Saved offline");
                                      } else {
                                        articlesBox.deleteAt(offlineIndex);
                                        showSnackBar(context, content: "Deleted");
                                      }
                                      articlesBox.flush();
                                      _offlineArticlesIN.refresh();
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
      if (_loweredSearchText.isNotEmpty) {
        s.addAll((_offlineModeIN.state ? _offlineArticlesIN : _onlineArticlesIN).state.where(
              (element) =>
                  element.title.toLowerCase().contains(_loweredSearchText) ||
                  (element.author != null && element.author!.toLowerCase().contains(_loweredSearchText)) ||
                  (element.source != null && element.source!.name.toLowerCase().contains(_loweredSearchText)),
            ));
      } else {
        s.addAll((_offlineModeIN.state ? _offlineArticlesIN : _onlineArticlesIN).state);
      }
      s.sort((a1, a2) {
        if (_sortModeIN.state == SortMode.oldestFirst) {
          return a1.publishedAt!.compareTo(a2.publishedAt!);
        } else {
          return a2.publishedAt!.compareTo(a1.publishedAt!);
        }
      });
    });
  }
}
