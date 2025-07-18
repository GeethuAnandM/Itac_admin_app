import 'dart:io';
import 'dart:math';
import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/reports/distanceReport.dart';
import 'package:admin_app/screens/reports/routeReport.dart';
import 'package:admin_app/screens/reports/speedReport.dart';
import 'package:admin_app/screens/reports/stopReport.dart';
import 'package:admin_app/screens/sidebar.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../languges/language_constants.dart';
import '/screens/themes.dart';
import 'package:flutter/material.dart';
import 'custom_widget.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;

class ReportsScreen extends StatefulWidget {
  ReportsScreen({required this.vehicleList, required this.vehicleDetailslist});
  List<Map<String, dynamic>> vehicleList = [];
  List<dynamic> vehicleDetailslist = [];

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final reportIntervalController = TextEditingController();
  var reportInterval = 15;
  var averageSpeed = 50;

  bool isHomePageSelected = true;
  GlobalKey<ScaffoldState> _key = GlobalKey();

  Widget _icon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(13)),
        // color: commonTextStyle,
      ),
      child: InkWell(
        onTap: () {
          _key.currentState?.openDrawer();
        },
        child: Icon(
          icon,
          size: 30,
        ),
      ),
    );
  }

  Future<void> createPDF() async {
    //Create a PDF document.
    final PdfDocument document = PdfDocument();

    //Add page to the PDF
    final PdfPage page = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();
    //Draw rectangle
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfColor(142, 170, 219, 255)));
    //Generate PDF grid.
    final PdfGrid grid = getGrid();
    //Draw the header section by creating text element
    final PdfLayoutResult? result = await drawHeader(page, pageSize, grid);
    //Draw grid
    drawGrid(page, grid, result!);
    // drawFooter(page, pageSize);
    //Save and launch the document
    List<int> bytes = await document.save();

    // Dispose the document
    document.dispose();

    //Save the file and launch/download
    SaveFile.saveAndLaunchFile(bytes,
        'Reports_Adminapp_${DateTime.now().microsecondsSinceEpoch.toString()}.pdf');
  }

  Future<PdfLayoutResult?> drawHeader(
      PdfPage page, Size pageSize, PdfGrid grid) async {
    //Draw rectangle
    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(91, 126, 215, 255)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 115, 90));
    //Draw string
    page.graphics.drawString(
        'Report', PdfStandardFont(PdfFontFamily.helvetica, 30),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, 0, pageSize.width - 115, 90),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 90),
        brush: PdfSolidBrush(PdfColor(65, 104, 205)));
    // var url = "http://13.233.175.113/assets/images/logo-itac.png";
    // var response = await get(Uri.parse(url));
    // var data = response.bodyBytes;
    // page.graphics.drawImage(
    //     PdfBitmap(data), Rect.fromLTWH(350, 0, pageSize.width - 200, 100));
    // page.graphics.drawString(
    //     '\$' + "200000", PdfStandardFont(PdfFontFamily.helvetica, 18),
    //     bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 100),
    //     brush: PdfBrushes.white,
    //     format: PdfStringFormat(
    //         alignment: PdfTextAlignment.center,
    //         lineAlignment: PdfVerticalAlignment.middle));

    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    //Draw string
    // page.graphics.drawString('Amount', contentFont,
    //     brush: PdfBrushes.white,
    //     bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 33),
    //     format: PdfStringFormat(
    //         alignment: PdfTextAlignment.center,
    //         lineAlignment: PdfVerticalAlignment.bottom));
    //Create data format and convert it to text.
    final DateFormat format = DateFormat.yMMMMd('en_US');
    Random random = Random();
    int randomNumber = random.nextInt(100);
    final String invoiceNumber =
        'Report Number: $randomNumber${DateTime.now().microsecondsSinceEpoch.toString()}\r\n\r\nDate: ${format.format(DateTime.now())}';
    final Size contentSize = contentFont.measureString(invoiceNumber);
    // const String address =
    // 'Bill To: \r\n\r\nAbraham Swearegin, \r\n\r\nUnited States, California, San Mateo, \r\n\r\n9920 BridgePointe Parkway, \r\n\r\n9365550136';

    return PdfTextElement(text: invoiceNumber, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(pageSize.width - (contentSize.width + 30), 120,
            contentSize.width + 30, pageSize.height - 120));

    // return PdfTextElement(text: address, font: contentFont).draw(
    //     page: page,
    //     bounds: Rect.fromLTWH(30, 120,
    //         pageSize.width - (contentSize.width + 30), pageSize.height - 120));
  }

  //Create PDF grid and return
  PdfGrid getGrid() {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 6);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'Sl No';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'Vehicle Name';
    headerRow.cells[2].value = 'Date Time';
    headerRow.cells[3].value = 'Distance';
    headerRow.cells[4].value = 'Cumulative Distance (KM)';
    headerRow.cells[5].value = 'Location';
    print(showvehicleDetailslist.length);
    for (int i = 0; i < showvehicleDetailslist.length; i++) {
      addProducts(
          "${i + 1}",
          showvehicleDetailslist[i].VehicleName.toString(),
          showvehicleDetailslist[i].VehicleName.toString(),
          showvehicleDetailslist[i].VehicleId.toString(),
          showvehicleDetailslist[i].VehicleId.toString(),
          showvehicleDetailslist[i].VehicleName.toString(),
          grid);
    }
    // addProducts('LJ-0192', 'Long-Sleeve Logo Jersey,M', 49.99, 3, 149.97, grid);
    // addProducts('So-B909-M', 'Mountain Bike Socks,M', 9.5, 2, 19, grid);
    // addProducts('LJ-0192', 'Long-Sleeve Logo Jersey,M', 49.99, 4, 199.96, grid);
    // addProducts('FK-5136', 'ML Fork', 175.49, 6, 1052.94, grid);
    // addProducts('HL-U509', 'Sports-100 Helmet,Black', 34.99, 1, 34.99, grid);
    //Apply the grid built-in style.
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    grid.columns[1].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }

//Create row for the grid.
  void addProducts(
      String slNo,
      String vehicleName,
      String datetime,
      String distance,
      String cumulativeDistance,
      String location,
      PdfGrid grid) {
    PdfGridRow row = grid.rows.add();
    row.cells[0].value = slNo;
    row.cells[1].value = vehicleName;
    row.cells[2].value = datetime;
    row.cells[3].value = distance;
    row.cells[4].value = cumulativeDistance;
    row.cells[5].value = location;
  }

  void drawGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    Rect? totalPriceCellBounds;
    Rect? quantityCellBounds;
    //Invoke the beginCellLayout event.
    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };
    //Draw the PDF grid and get the result.
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;

    //Draw grand total.
    // page.graphics.drawString('Grand Total',
    //     PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
    //     bounds: Rect.fromLTWH(
    //         quantityCellBounds!.left,
    //         result.bounds.bottom + 10,
    //         quantityCellBounds!.width,
    //         quantityCellBounds!.height));
    // page.graphics.drawString("20000",
    //     PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
    //     bounds: Rect.fromLTWH(
    //         totalPriceCellBounds!.left,
    //         result.bounds.bottom + 10,
    //         totalPriceCellBounds!.width,
    //         totalPriceCellBounds!.height));
  }

  // void drawFooter(PdfPage page, Size pageSize) {
  //   final PdfPen linePen =
  //       PdfPen(PdfColor(142, 170, 219, 255), dashStyle: PdfDashStyle.custom);
  //   linePen.dashPattern = <double>[3, 3];
  //   //Draw line
  //   page.graphics.drawLine(linePen, Offset(0, pageSize.height - 100),
  //       Offset(pageSize.width, pageSize.height - 100));

  //   const String footerContent =
  //       '800 Interchange Blvd.\r\n\r\nSuite 2501, Austin, TX 78721\r\n\r\nAny Questions? support@adventure-works.com';

  //   //Added 30 as a margin for the layout.
  //   page.graphics.drawString(
  //       footerContent, PdfStandardFont(PdfFontFamily.helvetica, 9),
  //       format: PdfStringFormat(alignment: PdfTextAlignment.right),
  //       bounds: Rect.fromLTWH(pageSize.width - 30, pageSize.height - 70, 0, 0));
  // }

  Widget _appBar() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RotatedBox(
            quarterTurns: 4,
            child: _icon(
              Icons.menu,
              // color: blueColor,
            ),
          ),
        ],
      ),
    );
  }
  // var vehicleName = widget.vehicleList[0].toString();
  // dynamic vehicleName = vehicleList[0];

  // print(widget.vehicleList[0]);
  List<Vehicles> showvehicleDetailslist = [];
  bool downloadpdf = false;
  List<Widget> Addvehicles() {
    print(
        "Total length of total vehicle is that: ${widget.vehicleList.length}");
    for (var i = 0; i < widget.vehicleDetailslist.length; i++) {
      // print(deviceLocationList[i]['vehicleStatus']);
      // print(deviceLocationList[i]['deviceStatus']);
      // for(var j=0;j<widget.deviceLocationList.length;j++) {
      showvehicleDetailslist.add(Vehicles(
        VehicleModel: widget.vehicleDetailslist[i]['model'],
        VehicleName: widget.vehicleDetailslist[i]['vehicleName'],
        VehicleStatus: widget.vehicleDetailslist[i]['model'],
        LastReportedTime: widget.vehicleDetailslist[i]['model'],
        VehicleId: widget.vehicleDetailslist[i]['model'],
      ));

      // }
    }

    setState(() {
      filterclicked = true;
      showvehicleDetailslist = showvehicleDetailslist;
      downloadpdf = true;
    });

    List<Widget> Demo = [];
    return Demo;
  }

  List<dynamic> vehicleList = [];
  List<Map<String, dynamic>> vehicleNames = [];
  var reportspageclicked = false;
  Future<void> getVehiclesNames() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    final url = "${baseUrl}api/list-vehicles/$userId";
    //show error message try catch
    try {
      var dio = Dio();
      final response = await dio.get(url);
      vehicleList = response.data;
      print("length of Vehicle list is:${vehicleList.length}");
      vehicleNames = [];
      for (var i in vehicleList) {
        vehicleNames.add({"name": i['vehicleName'], "id": i['vehicleId']});
      }
      print(vehicleNames);
    } catch (e) {
      print(e);
    }
    print("all names and id's:${vehicleNames}");
  }

  var filterclicked;

  @override
  Widget build(BuildContext context) {
    // final pdf = pw.Document();
    // void downloadpdf() async{
    //
    //   final pdf = pw.Document();
    //
    //   pdf.addPage(
    //     pw.Page(
    //       build: (pw.Context context) => pw.Center(
    //         child: pw.Text('Hello World!'),
    //       ),
    //     ),
    //   );
    //
    //   final file = File('suffix.pdf');
    //   await file.writeAsBytes(await pdf.save());
    // }
    // Page

    final _items = widget.vehicleList
        .map((Vehiclesnames) =>
            MultiSelectItem(Vehiclesnames, Vehiclesnames.toString()))
        .toList();

    // print(widget.vehicleList[0]);
    // var vehicleName = widget.vehicleList[0].toString();
    return Scaffold(
      key: _key,
      drawer: const NavBar(),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            centerTitle: true,
            leading:
                Padding(padding: EdgeInsets.only(top: 15), child: _appBar()),
            title: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(translation(context).reports)),
            elevation: 0,
          )),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          color: Colors.white54,
          height: 900,
          child: ContainedTabBarView(
            tabs: [
              Container(
                  height: 50,
                  child: Center(
                      child: Text(
                    'Distance',
                    style: blackTextStyle,
                  ))),
              Container(
                  height: 50,
                  child: Center(
                      child: Text(
                    'Speed',
                    style: blackTextStyle,
                  ))),
              Container(
                  height: 50,
                  child: Center(
                      child: Text(
                    'Route',
                    style: blackTextStyle,
                  ))),
              Container(
                  height: 50,
                  child: Center(
                      child: Text(
                    'Stop',
                    style: blackTextStyle,
                  ))),
            ],
            views: [
              // Text("hhh"),
              // DistanceReport(),
              DistanceReportsScreen(
                  vehicleList: widget.vehicleList,
                  vehicleDetailslist: widget.vehicleDetailslist),
              SpeedReportsScreen(
                  vehicleList: widget.vehicleList,
                  vehicleDetailslist: widget.vehicleDetailslist),
              RouteReportsScreen(
                  vehicleList: widget.vehicleList,
                  vehicleDetailslist: widget.vehicleDetailslist),
              //routereport
              StopReportsScreen(
                  vehicleList: widget.vehicleList,
                  vehicleDetailslist: widget.vehicleDetailslist),
              // Container(color: Colors.green),
            ],
            onChange: (index) => print(index),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("dispose");
    super.dispose();
  }
}

class Vehicles {
  var VehicleName;
  var VehicleModel;
  var VehicleStatus;
  var LastReportedTime;
  var VehicleId;

  Vehicles({
    required this.VehicleStatus,
    required this.VehicleModel,
    required this.LastReportedTime,
    required this.VehicleName,
    required this.VehicleId,
  });
}

class SaveFile {
  static Future<void> saveAndLaunchFile(
      List<int> bytes, String fileName) async {
    //Get external storage directory
    // final directory =
    //     (await getExternalStorageDirectories(type: StorageDirectory.downloads))!
    //         .first;

    final directory = Directory('/storage/emulated/0/Download');

    //Get directory path
    String path = directory.path;
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    //Create an empty file to write PDF data
    File file = await File('$path/$fileName').create(recursive: true);
    //Write PDF data
    await file.writeAsBytes(bytes, flush: true);
    //Open the PDF document in mobile
    if (file.existsSync()) {
      OpenFilex.open('$path/$fileName');
    }
  }
}
