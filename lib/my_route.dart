import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import './my_code_view.dart';
import './my_app_meta.dart' as my_app_meta;

abstract class MyRoute extends StatefulWidget {
  // Path of source file (relative to project root). The file's content will be
  // shown in the "Code" tab.
  final String _sourceFile;

  const MyRoute(this._sourceFile);

  // Subclasses can return routeName accordingly (polymorphism).
  String get routeName => '/${this.runtimeType.toString()}';

  // Title shown in the route's appbar and in the app's navigation drawer item.
  // By default just returns routeName.
  String get title => this.routeName;

  // A short description of the route. If not null, will be shown as subtitle in
  // app's navigation drawer.
  String get description => null;

  // Returns a set of links {title:link} that are relative to the route. Can put
  // documention links or reference video/article links here.
  Map<String, String> get links => {};

  // Returns the widget that will be shown in the "Preview" tab.
  Widget buildMyRouteContent(BuildContext context);

  @override
  State<StatefulWidget> createState() => _MyRouteState();
}

// Each MyRoute contains two tabs: "Preview" and "Code".
const _TABS = <Widget>[
  Tab(
    // text: 'Preview',
    // icon: Icon(Icons.phone_android),
    child: ListTile(
      leading: Icon(
        Icons.phone_android,
        color: Colors.white,
      ),
      title: Text(
        'Preview',
        style: TextStyle(color: Colors.white),
      ),
    ),
  ),
  Tab(
    // text: 'Code',
    // icon: Icon(Icons.code),
    child: ListTile(
      leading: Icon(
        Icons.code,
        color: Colors.white,
      ),
      title: Text(
        'Code',
        style: TextStyle(color: Colors.white),
      ),
    ),
  ),
];

class _MyRouteState extends State<MyRoute> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _TABS.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appbarActions = <Widget>[];
    if (this.widget.links.isNotEmpty) {
      final popMenu = PopupMenuButton(
        itemBuilder: (context) {
          var menuItems = <PopupMenuItem>[];
          this.widget.links.forEach((title, link) {
            menuItems.add(
              PopupMenuItem(
                child: ListTile(
                  title: Text(title),
                  trailing: IconButton(
                    icon: Icon(Icons.open_in_new),
                    tooltip: '$link',
                    onPressed: () => url_launcher.launch(link),
                  ),
                  onTap: () => url_launcher.launch(link),
                ),
              ),
            );
          });
          return menuItems;
        },
      );
      appbarActions.add(popMenu);
    }

    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(this.widget.title),
        ),
        actions: appbarActions,
        bottom: TabBar(
          tabs: _TABS,
          controller: this._tabController,
        ),
      ),
      // Use a Builder so that Scaffold.of(context) uses correct context, c.f.
      // https://stackoverflow.com/a/45948913
      body: Builder(builder: (BuildContext context) {
        final myTabPages = <Widget>[
          // "Preview" tab:
          this.widget.buildMyRouteContent(context),
          // "Code" tab:
          MyCodeView(filePath: this.widget._sourceFile),
        ];
        assert(myTabPages.length == _TABS.length);
        // Body of MyRoute is two-tabs ("Preview" and "Code").
        return TabBarView(
          children: myTabPages,
          controller: this._tabController,
        );
      }),
      // Only home route has drawer:
      drawer: this.widget.routeName == Navigator.defaultRouteName
          ? Drawer(
              child: my_app_meta.getNavDrawerItems(this, context),
            )
          : null,
    );
  }
}
