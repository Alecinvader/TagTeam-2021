import 'package:flutter/material.dart';
import 'package:tagteamprod/models/tagteam.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/team_api.dart';
import 'package:tagteamprod/ui/primary/home_widgets/home_team_tile.dart';
import 'package:tagteamprod/ui/utility/core/better_future_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<TagTeam>> future;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = TeamApi().getAllTeams(SnackbarErrorHandler(context));
    // future = Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text('Home'),
        ),
      ),
      body: SimpleFutureBuilder(
        builder: (BuildContext context, List<TagTeam>? data) {
          return SafeArea(
            child: Column(
              children: [
                Flexible(
                    child: ListView.builder(
                  itemBuilder: (context, index) {
                    return MiniDashboardTile(team: data![index]);
                  },
                  itemCount: data?.length ?? 0,
                ))
              ],
            ),
          );
        },
        future: future,
      ),
    );
  }
}
