import 'dart:convert';

import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/Hive_model.dart';
import '../../services/ApiService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../models/Dataset_model.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

class CartesianHiveView extends StatefulWidget {
  final Hive hive;
  final DateTime lastDay;
  final DateTime firstDay;
  final List<String> selectedSensor;
  const CartesianHiveView(
      {Key? key,
      required this.hive,
      required this.lastDay,
      required this.firstDay,
      required this.selectedSensor})
      : super(key: key);

  @override
  State<CartesianHiveView> createState() => _CartesianHiveViewState();
}

class _CartesianHiveViewState extends State<CartesianHiveView> {
  String hive = "";
  bool _isLoading = false;
  String? _filePath;
  late GlobalKey<SfCartesianChartState> _cartesianChartKey;
  bool _isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    _cartesianChartKey = GlobalKey();
  }




  void _handleButtonPress() {
    if (!_isButtonDisabled) {
      setState(() {
        _isButtonDisabled = true;
      });
    }
  }

  void _trueButton() {
    if (_isButtonDisabled) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isButtonDisabled = false;
        });
      });
    }
  }

  ///retrieve all the data from the sensors to select
  Future<List<List<Dataset>?>> waitForFutures() async {
    List<Future<List<Dataset>?>> futures = [];

    int tailleSelectedOjet = widget.selectedSensor.length;
    String id = widget.hive.hiveid.toString();
    print("id $id");
    String dernierjour = DateFormat('yyyy-MM-dd').format(widget.lastDay);
    String premierjour = DateFormat('yyyy-MM-dd').format(widget.firstDay);

    print("les jour selectionner $premierjour $dernierjour");

    for (int i = 0; i < tailleSelectedOjet; i++) {
      if (i >= 0 && i < widget.selectedSensor.length) {
        futures.add(getDatasetFromSQLiteorApi(widget.selectedSensor[i],
            widget.hive, premierjour, dernierjour));
      }
    }


    List<dynamic> capteur = widget.selectedSensor;

    if(widget.selectedSensor != null){
      BackupGraphic();
      BackupSensor();
      BackupLastDay();
      BackupFirstDay();
      BackupHive();
    }





    return Future.wait(futures);
  }

  Future<void> BackupHive() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(
        'hive', widget.hive.hiveid!);
  }

  Future<void> BackupSensor() async {
    final widgetStrings = widget.selectedSensor.map((widget) => widget).toList();
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'sensor', widgetStrings);
  }

  Future<void> BackupGraphic() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'graphic', "Cartesian");
  }

  Future<void> BackupLastDay() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'lastday', widget.lastDay.toString());
  }

  Future<void> BackupFirstDay() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'firstday', widget.firstDay.toString());
  }



  ///generate graph according to sensor selected and timestamp
  List<ChartSeries> generateLineSeries(List<List<Dataset>?>? datasets) {
    List<ChartSeries> seriesList = [];

    if (datasets != null && datasets.length == widget.selectedSensor.length) {
      print(datasets);
      for (int i = 0; i < datasets.length; i++) {
        List<Dataset>? currentDataset = datasets[i];
        String currentCapteur = widget.selectedSensor[i];

        if (currentDataset != null) {
          currentDataset.sort((a, b) => a.timestamp.compareTo(b.timestamp));

          LineSeries<Dataset, DateTime> currentSeries = LineSeries<
              Dataset,
              DateTime>(
            dataSource: currentDataset,
            xValueMapper: (Dataset data, _) => DateTime.parse(data.timestamp),
            yValueMapper: (Dataset data, _) => data.Data,
            name: currentCapteur,
            dataLabelSettings: DataLabelSettings(isVisible: false),
          );

          seriesList.add(currentSeries);
        }
      }
    }

    return seriesList;
  }


    ///create pdf and register in the application
  Future<void> _createPDF() async {
    setState(() {
      _isLoading = true;
    });
    final filePath;
    LocalFileSystem localFileSystem = LocalFileSystem();
    Directory? externalDir =
    localFileSystem.directory('storage/emulated/0/Documents');
    if (externalDir != null) {
      String imageFolderPath = '${externalDir.path}/MesImages';
      await localFileSystem.directory(imageFolderPath).create(recursive: true);
      print('Dossier créé : $imageFolderPath');
      filePath = '${imageFolderPath}/${widget.hive.Name}graphBar.png';
      final file = File(filePath);


      final doc = pdf.Document();
      final imageBytes = await _getImageBytes();
      file.writeAsBytes(await _getImageBytes());


      //ImageGallerySaver.saveImage(imageBytes,name: "./Manabees/${widget.hive.Name}");

      /*doc.addPage(pdf.Page(
        build: (pdf.Context context) {
          return pdf.Center(
            child: pdf.Transform.rotate(
                angle: 3.14159 / 2,
                child: pdf.Image(pdf.MemoryImage(imageBytes))),
          );
        },
      ));*/

      //await file.writeAsBytes(await doc.save());

      setState(() {
        _isLoading = false;
        _filePath = filePath;
      });
    }
  }

  Future<Uint8List> _getImageBytes() async {
    RenderRepaintBoundary boundary = _cartesianChartKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 10.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  ///transfert message vers l'api
  Future<void> _sendEmail() async {
    //final smtpServer = gmail('mali.guillaume1998@gmail.com', '70020898');
    final smtpServer = SmtpServer('smtp-mail.outlook.com',
        port: 587,
        ssl: false,
        username: '',
        password: '');

    final message = Message()
      ..from = Address('mali.guillaume@outlook.com', 'Guillaume Mali')
      ..recipients.add('mali.guillaume24@gmail.com')
      ..subject = 'Graph PDF'
      ..attachments.add(FileAttachment(File(_filePath!)))
      ..html = 'Attached is a PDF file containing a graph.';

    /*try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent: ' + e.toString());
    } catch (e) {
      print('Message not sent: ' + e.toString());
    }*/

    String platformResponse;

    try {
      await send(message, smtpServer);
      platformResponse = 'send email';
    } catch (error) {
      print(error);
      platformResponse = error.toString();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(platformResponse),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    hive = widget.hive.Name;
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Expanded(
          child: FutureBuilder<List<List<Dataset>?>>(
        future: waitForFutures(),
        builder: (BuildContext context,
            AsyncSnapshot<List<List<Dataset>?>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty || snapshot.data!.length >= 0) {
              List<List<Dataset>?>? datasets = snapshot.data;
              String lastDay =
                  DateFormat('yyyy-MM-dd').format(widget.lastDay);
              String firstDay =
                  DateFormat('yyyy-MM-dd').format(widget.firstDay);
              Duration date;
              date = widget.lastDay.difference(widget.firstDay);
              print("diff jour : ${date.inDays}");
              DateTimeAxis xAxis = DateTimeAxis(
                  dateFormat: date.inDays < 180
                      ? DateFormat('dd-MM-yyyy HH:mm')
                      : DateFormat('dd-MM-yyyy'),
                  minimum: datasets != null && datasets.isNotEmpty
                      ? DateTime.parse(firstDay)
                      : null,
                  maximum: datasets != null && datasets.isNotEmpty
                      ? DateTime.parse(lastDay).add(Duration(days: 1))
                      : null);

              return SfCartesianChart(
                key: _cartesianChartKey,
                primaryXAxis: xAxis,

                // Chart title
                title: ChartTitle(text: 'Data on $hive'),
                // Enable legend
                legend: Legend(isVisible: true),
                // Enable tooltip
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  color: Colors.grey,
                  borderColor: Colors.grey,
                  borderWidth: 1,
                  duration: 2000,
                ),
                series: generateLineSeries(snapshot.data),
                zoomPanBehavior: ZoomPanBehavior(
                    enablePanning: true,
                    enablePinching: true,
                    enableDoubleTapZooming: true,
                    zoomMode: ZoomMode.x),
              );
            } else {
              return SizedBox();
            }
          } else if (snapshot.hasError) {
            return Text(
                'Not data with sensor');
          } else {
            return Shimmer.fromColors(
                direction: ShimmerDirection.btt,
                baseColor: Colors.grey,
                highlightColor: Colors.grey,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          series: <ChartSeries>[
                            LineSeries<double, double>(
                              dataSource: [1, 5, 2, 5, 3, 6, 4, 5, 5, 4],
                              xValueMapper: (double value, _) => value,
                              yValueMapper: (double value, _) => value,
                            )
                          ],
                        ),
                      ),
                    ]));
          }
        },
      )),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () async {
                final pdf = await _createPDF();
                //_sendEmail();

              },
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.yellow),
              ),
              child: const Text("Generate image")),
          SizedBox(width: 20,),
          TextButton(
              onPressed: _isButtonDisabled
                  ? null
                  : () async {
                _handleButtonPress();
                final pdf = await _createPDF();
                _sendEmail();
                _trueButton();
              },
              style: ButtonStyle(
                backgroundColor: _isButtonDisabled
                    ? MaterialStateProperty.all<Color>(Colors.grey)
                    : MaterialStateProperty.all<Color>(Colors.yellow),
              ),
              child: const Text("Send a email"))
        ],
      )

    ]);
  }
}


