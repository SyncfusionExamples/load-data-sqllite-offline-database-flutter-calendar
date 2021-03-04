import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'database_helper.dart';

void main() => runApp(SQLData());

class SQLData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GetSQLData(),
    );
  }
}

class GetSQLData extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyHomePage();
}

class MyHomePage extends State<GetSQLData> {
// reference to our single class that manages the database
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Color> _colorCollection;
  List<String> _views;

  @override
  void initState() {
    _initializeEventColor();
    _views = <String>[
      'Insert',
      'Query',
      'Update',
      'Delete',
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('SQL data'),
            leading: PopupMenuButton<String>(
              icon: Icon(Icons.calendar_today),
              itemBuilder: (BuildContext context) =>
                  _views.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
              onSelected: (String value) {
                setState(() {
                  if (value == 'Insert') {
                    _insert();
                  } else if (value == 'Query') {
                    _query();
                  } else if (value == 'Update') {
                    _update();
                  } else {
                    _delete();
                  }
                });
              },
            )),
        body: FutureBuilder(
            future: dbHelper.getAllRecords("flutter_calendar_events"),
            builder: (context, snapshot) {
              List<Appointment> collection = <Appointment>[];
              if (snapshot.data != null) {
                return ListView.builder(
                  itemCount: 1,
                  itemExtent: 550,
                  itemBuilder: (context, int position) {
                    var item = snapshot.data[position];
                    Random random = new Random();
                    for (int i = 0; i < snapshot.data.length; i++) {
                      collection.add(
                        Appointment(
                          subject: item.row[1],
                          startTime: _convertDateFromString(item.row[2]),
                          endTime: _convertDateFromString(item.row[3]),
                          color: _colorCollection[random.nextInt(9)],
                        ),
                      );
                    }
                    return SfCalendar(
                      view: CalendarView.month,
                      initialDisplayDate: DateTime(2021, 1, 4, 9, 0, 0),
                      monthViewSettings: MonthViewSettings(showAgenda: true),
                      dataSource: _getCalendarDataSource(collection),
                    );
                  },
                );
              } else {
                return CircularProgressIndicator();
              }
            }));
  }

  void _insert() async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: 'Bob',
      DatabaseHelper.columnStart: DateTime(2021, 1, 3, 9, 0, 0).toString(),
      DatabaseHelper.columnEnd: DateTime(2021, 1, 3, 10, 0, 0).toString(),
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    allRows.forEach((row) => print(row));
  }

  void _update() async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnName: 'Planning',
      DatabaseHelper.columnStart: DateTime(2021, 1, 4, 9, 0, 0).toString(),
      DatabaseHelper.columnEnd: DateTime(2021, 1, 4, 10, 0, 0).toString(),
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
  }

  void _delete() async {
    // Assuming that the number of rows is the id for the last row.
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');
  }

  _AppointmentDataSource _getCalendarDataSource(List<Appointment> collection) {
    List<Appointment> appointments = collection ?? <Appointment>[];
    return _AppointmentDataSource(appointments);
  }

  DateTime _convertDateFromString(String date) {
    return DateTime.parse(date);
  }

  void _initializeEventColor() {
    // ignore: deprecated_member_use
    _colorCollection = List<Color>();
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF36B37B));
    _colorCollection.add(const Color(0xFF01A1EF));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));
    _colorCollection.add(const Color(0xFF0A8043));
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
