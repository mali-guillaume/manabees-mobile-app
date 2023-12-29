import 'package:flutter/material.dart';
import '../../services/ApiService.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/Dataset_model.dart';

class CartesianView extends StatefulWidget {
  const CartesianView({Key? key}) : super(key: key);

  @override
  State<CartesianView> createState() => _CartesianViewState();
}

class _CartesianViewState extends State<CartesianView> {
  String data = 'temp1';
  String data2 = 'temp2';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<Dataset>>>(
      future: Future.wait([httpService().getDataset(data),httpService().getDataset(data2)]),
      builder: (BuildContext context,
          AsyncSnapshot<List<List<Dataset>>> snapshot) {
        if (snapshot.hasData) {
          return SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            // Chart title
            title: ChartTitle(text: 'Donnée utilisé'),
            // Enable legend
            legend: Legend(isVisible: true),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <ChartSeries>[
              LineSeries<Dataset, String>(
                  dataSource: snapshot.data![0],
                  xValueMapper: (Dataset data, _) => data.timestamp,
                  yValueMapper: (Dataset data, _) => data.Sensor,
                  name: data,
                  dataLabelSettings: DataLabelSettings(isVisible: true)
              ),
              LineSeries<Dataset, String>(
                  dataSource: snapshot.data![1],
                  xValueMapper: (Dataset data, _) => data.timestamp,
                  yValueMapper: (Dataset data, _) => data.Sensor,
                  name: data2,
                  dataLabelSettings: DataLabelSettings(isVisible: true)
              ),
            ],
          );
          //return Text(snapshot.data.toString());
        } else if (snapshot.hasError) {
          return Text('Une erreur est survenue : ${snapshot.error}');
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
