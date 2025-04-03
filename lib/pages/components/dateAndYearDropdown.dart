import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_realtime_location/models/Ad.dart';
import 'package:rider_realtime_location/models/rides_model.dart';
import 'package:rider_realtime_location/services/database_service.dart';

class MonthAndYear extends StatefulWidget {
  final String? rId;
  final String? adId;
  final Function? setMonthYear;
  const MonthAndYear({super.key, required this.adId, required this.rId, required this.setMonthYear});

  @override
  State<MonthAndYear> createState() => _MonthAndYearState();
}

class _MonthAndYearState extends State<MonthAndYear> {
  String _selectedMonth="";
  String _selectedYear="";
  
  @override
  Widget build(BuildContext context) {
    void setSelectedYear(String year){
    setState(() {
      _selectedYear=year;
    });
  }
  
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        
        /**
         * DropdownButton<String>(
                  value: _selectedYear,
                  hint: Text('Select Month',),
                  items: _months.map((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(month),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMonth = newValue;
                    });
                  },
                ),
         */
        if(_selectedYear!="")
        StreamProvider<List<String>>.value(
        value: DatabaseService(riderId:widget.rId,adId: widget.adId,year: _selectedYear).getMonths,
        initialData: List.empty(),
        child:MyMonths(year: _selectedYear,setMonthYear: widget.setMonthYear,) ,),
        
        SizedBox(width: 8,),
        StreamProvider<List<String>>.value(
        value: DatabaseService(riderId:widget.rId,adId: widget.adId).getYears,
        initialData: List.empty(),
        child:MyYear(setSelectedYear: setSelectedYear,) ,),
        
      ],
    );
  }
}

class MyYear extends StatefulWidget {
  final Function? setSelectedYear;
  const MyYear({super.key, required this.setSelectedYear});

  @override
  State<MyYear> createState() => _MyYearState();
}

class _MyYearState extends State<MyYear> {
  String? _selectedYear;
  @override
  Widget build(BuildContext context) {
    DateTime currDate=new DateTime.now();
    
    
    List<String> _years = List.generate(5, (index) => (currDate.year - index).toString()); 
    final years = Provider.of<List<String>?>(context);
    return DropdownButton<String>(
                  value: _selectedYear,
                  hint: Text('Select Year',),
                  items: _years.map((String year) {
                    return DropdownMenuItem<String>(
                      value:year,
                      child: Text(year,style: TextStyle(color: (years!=null && years.contains(year))?Colors.black:Colors.grey),),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if(years!=null && years.contains(newValue)){
                      setState(() {
                      _selectedYear = newValue;
                    });
                    widget.setSelectedYear!(newValue);
                    }
                  },
                );
  }
}

class MyMonths extends StatefulWidget {
  final Function? setMonthYear;
  final String? year;
  const MyMonths({super.key, required this.setMonthYear, required this.year});

  @override
  State<MyMonths> createState() => _MyMonthsState();
}

class _MyMonthsState extends State<MyMonths> {
  final List<String> _months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
  String? _selectedMonth;
  @override
  Widget build(BuildContext context) {
    final months = Provider.of<List<String>?>(context);
    return DropdownButton<String>(
                  value: _selectedMonth,
                  hint: Text('Select Month',),
                  items: _months.map((String month) {
                    return DropdownMenuItem<String>(
                      value:month,
                      child: Text(month,style: TextStyle(color: (months!=null && months.contains(month))?Colors.black:Colors.grey),),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if(months!=null && months.contains(newValue)){
                      setState(() {
                      _selectedMonth = newValue;
                    });
                    widget.setMonthYear!(newValue, widget.year);
                    }
                  },
                );
  }
}

class MyDays extends StatefulWidget {
  final Function? viewTrail;
  final Function? selectDay;
  final String? rid;
  final String? adId;
  final String? yy;
  final String? mm;
  final int? dd;
  const MyDays({super.key, required this.selectDay, required this.viewTrail, required this.adId, required this.mm, required this.rid, required this.yy, required this.dd});

  @override
  State<MyDays> createState() => _MyDaysState();
}

class _MyDaysState extends State<MyDays> {
  @override
  Widget build(BuildContext context) {
    final days = Provider.of<List<String>?>(context);
    
    return Column(
      children: [
        for(int i=0;i<7; i++)
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for(int j=1;j<=7; j++)
                          if((7*i+j)<=35 && (7*i+j)>0 )
                            InkWell(
                              onTap: ()async{
                                if(days!=null && days.contains("${(7*i+j)}") && widget.dd!=(7*i+j)){
                                  if(i<=31){
                                    setState(() {
                                    widget.selectDay!(7*i+j);
                                  });
                                                                
                                  }
                                  final _db=DatabaseService(riderId: widget.rid, );
                                  //String? adId, String? yyyy, String? mm, String dd
                                  List<RidesModel> rides=await  _db.getDocuments(widget.adId,widget.yy,widget.mm,"${(7*i+j)}");
                                  widget.viewTrail!(rides);
                                }
                                
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: ((7*i+j)<=31)?(widget.dd==7*i+j)?Colors.red[500]:Colors.white:Colors.white,
                                    borderRadius: BorderRadius.circular(15),  // Set border radius here
                                  ),
                                width: 30,
                                height: 30,
                                child: Center(child: Text("${7*i+j}", style: TextStyle(fontWeight: FontWeight.bold, color: ((7*i+j)<=31)?(widget.dd==7*i+j)?Colors.white:(days!=null && days.contains("${7*i+j}"))?Colors.black:Colors.grey:Colors.white),))),
                            )
                          
                        ],
                      ),
                      SizedBox(height: 8,)
                    ],
                  )
      ],
    );
  }
}