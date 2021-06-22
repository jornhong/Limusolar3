import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';
import '../../model.dart';

class ActiveMonitorHist extends StatelessWidget {
  const ActiveMonitorHist({Key? key}) : super(key: key);
  static final dateFormat = DateFormat('yyyy-MM-dd hh:mm');

  @override
  Widget build(BuildContext context) {
    return Consumer<EventLog>(builder: (ctx, logs, child) {
      return ListView.separated(
          itemBuilder: (context, index) {
            var eventItem = logs.events[index];
            var dt = DateTime.now();
            dt = dt.add(Duration(seconds:  - (logs.deviceTime - eventItem.time)));
            String icon;
            if (eventItem.eventCatalog == 0x04) {
              icon = 'assets/images/error.png';
            } else {
              icon = 'assets/images/info.png';
            }
            String b1v = sprintf('%.02fV', [eventItem.battery1Vol]);
            String b2v = sprintf('%.02fV', [eventItem.battery2Vol]);
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child:  Row(
                children: [
                  Text(dateFormat.format(dt),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                              child: Text(eventItem.eventCatalogName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                            ),
                            Row(
                              children: [
                                Image.asset('assets/images/battery.png', width: 18,),
                                const SizedBox(width: 4,),
                                Text(b1v,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16,),
                                Image.asset('assets/images/battery.png', width: 18,),
                                const SizedBox(width: 4,),
                                Text(b2v,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                  ),
                  Opacity(
                    opacity: 0.4,
                    child: Image.asset(icon, width: 24, height: 24,),),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider(height: 1.0, color: Color(0xFF00DDDD));
          },
          itemCount: logs.logCount);
    });
  }
}
