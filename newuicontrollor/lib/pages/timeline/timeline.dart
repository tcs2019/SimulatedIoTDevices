import 'package:flutter/material.dart';
import 'package:newuicontrollor/web3/web3p.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
// import 'data.dart';

class TimelinePage extends StatefulWidget {
  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  List<Doodle> doodles = [];
  double totallytime = 0;
  _initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> readtimesnow = await Web3P.fetchReadtime();
    int readtimems = int.parse(readtimesnow[readtimesnow.length - 1]);
    int choosecolortime = prefs.getInt("ChooseColorTime");
    int submittime = prefs.getInt("SubmitTime");
    int receipttime = prefs.getInt("ReceiptTime");

    int eventtime = prefs.getInt("EventTime");
    int blocktime = eventtime - readtimems;
    int statuschangetime = prefs.getInt("StatusChangeTime");

    if (mounted) {
      setState(() {
        totallytime = (statuschangetime - choosecolortime)/1000.toDouble();
        doodles = [
          Doodle(
              timestamp: choosecolortime,
              name: "Choose Color Time",
              time: DateTime.fromMillisecondsSinceEpoch(choosecolortime)
                  .toString(),
              content: "",
              doodle: "",
              diff: choosecolortime - choosecolortime,
              icon: Icon(Icons.color_lens, color: Colors.white),
              iconBackground: Colors.cyan),
          Doodle(
              timestamp: submittime,
              name: "Transaction Submit Time",
              time: DateTime.fromMillisecondsSinceEpoch(submittime).toString(),
              content: "",
              doodle: "",
              diff: submittime - choosecolortime,
              icon: Icon(
                Icons.cloud_upload,
                color: Colors.white,
              ),
              iconBackground: Colors.redAccent),
          Doodle(
              timestamp: receipttime,
              name: "Blockchain Receive Request Time",
              time: DateTime.fromMillisecondsSinceEpoch(receipttime).toString(),
              content: "",
              doodle: "",
              diff: receipttime - submittime,
              icon: Icon(
                Icons.check_circle,
                color: Colors.black87,
                size: 32.0,
              ),
              iconBackground: Colors.yellow),
          Doodle(
              timestamp: eventtime,
              name: "Block Time/ Transaction Complete Time",
              time: DateTime.fromMillisecondsSinceEpoch(blocktime).toString(),
              content: "",
              doodle: "",
              diff: blocktime - receipttime,
              icon: Icon(
                Icons.attach_money,
                color: Colors.black87,
              ),
              iconBackground: Colors.amber),
          Doodle(
              timestamp: eventtime,
              name: "APP Receive Confirmation Time",
              time: DateTime.fromMillisecondsSinceEpoch(eventtime).toString(),
              content: "",
              doodle: "",
              diff: eventtime - blocktime,
              icon: Icon(
                Icons.cloud_download,
                color: Colors.black87,
              ),
              iconBackground: Colors.amber),
          Doodle(
              timestamp: statuschangetime,
              name: "Color Change Time",
              time: DateTime.fromMillisecondsSinceEpoch(statuschangetime)
                  .toString(),
              content: "",
              doodle: "",
              diff: statuschangetime - eventtime,
              icon: Icon(
                Icons.lightbulb_outline,
                color: Colors.white,
              ),
              iconBackground: Colors.green),
        ];
        // doodles.sort();
      });
    }
  }

  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Timeline"),
      ),
      body: timelineModel(TimelinePosition.Center),
    );
  }

  timelineModel(TimelinePosition position) => Timeline.builder(
      itemBuilder: centerTimelineBuilder,
      itemCount: doodles.length,
      physics: position == TimelinePosition.Left
          ? ClampingScrollPhysics()
          : BouncingScrollPhysics(),
      position: position);

  TimelineModel centerTimelineBuilder(BuildContext context, int i) {
    final doodle = doodles[i];
    final textTheme = Theme.of(context).textTheme;
    return TimelineModel(
        Card(
          margin: EdgeInsets.symmetric(vertical: 16.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Image.network(doodle.doodle),
                const SizedBox(
                  height: 8.0,
                ),
                Text(doodle.time, style: textTheme.caption),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  doodle.name,
                  style: textTheme.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text("${doodle.diff.toString()} ms/$totallytime s",
                    style: textTheme.caption),
              ],
            ),
          ),
        ),
        position:
            i % 2 == 0 ? TimelineItemPosition.right : TimelineItemPosition.left,
        isFirst: i == 0,
        isLast: i == doodles.length,
        iconBackground: doodle.iconBackground,
        icon: doodle.icon);
  }
}

class Doodle {
  final int timestamp;
  final String name;
  final String time;
  final String content;
  final String doodle;
  final Color iconBackground;
  final int diff;
  final Icon icon;
  const Doodle(
      {this.timestamp,
      this.name,
      this.time,
      this.content,
      this.doodle,
      this.diff,
      this.icon,
      this.iconBackground});
}
