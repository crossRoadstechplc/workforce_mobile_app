import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/leave_models.dart';

class LeaveDraft { const LeaveDraft({required this.leaveTypeId,required this.startDate,required this.endDate,required this.reason}); final String leaveTypeId; final DateTime startDate; final DateTime endDate; final String reason; }
Future<LeaveDraft?> showLeaveRequestSheet(BuildContext context,List<LeaveType> types)=>showModalBottomSheet<LeaveDraft>(context:context,isScrollControlled:true,useSafeArea:true,builder:(_)=>_LeaveRequestSheet(types:types));
class _LeaveRequestSheet extends StatefulWidget{const _LeaveRequestSheet({required this.types}); final List<LeaveType> types; @override State<_LeaveRequestSheet> createState()=>_State();}
class _State extends State<_LeaveRequestSheet>{
  String? typeId; DateTime? start; DateTime? end; final reason=TextEditingController();
  @override void dispose(){reason.dispose();super.dispose();}
  Future<void> pick(bool isStart) async { final initial=isStart?(start??DateTime.now()):(end??start??DateTime.now()); final value=await showDatePicker(context:context,firstDate:DateTime.now(),lastDate:DateTime(DateTime.now().year+2),initialDate:initial); if(value!=null)setState((){if(isStart){start=value;if(end!=null&&end!.isBefore(value))end=value;}else{end=value;}}); }
  @override Widget build(BuildContext context){ final valid=typeId!=null&&start!=null&&end!=null&&!end!.isBefore(start!)&&reason.text.trim().length>=5; return Padding(padding:EdgeInsets.fromLTRB(20,20,20,20+MediaQuery.viewInsetsOf(context).bottom),child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    Text('Request leave',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w700)),const SizedBox(height:16),
    DropdownButtonFormField<String>(value:typeId,decoration:const InputDecoration(labelText:'Leave type'),items:widget.types.map((t)=>DropdownMenuItem(value:t.id,child:Text(t.name))).toList(),onChanged:(v)=>setState(()=>typeId=v)),const SizedBox(height:12),
    Row(children:[Expanded(child:OutlinedButton.icon(onPressed:()=>pick(true),icon:const Icon(Icons.calendar_today_outlined),label:Text(start==null?'Start date':DateFormat('MMM d, yyyy').format(start!)))),const SizedBox(width:10),Expanded(child:OutlinedButton.icon(onPressed:()=>pick(false),icon:const Icon(Icons.event_outlined),label:Text(end==null?'End date':DateFormat('MMM d, yyyy').format(end!))))]),const SizedBox(height:12),
    TextField(controller:reason,minLines:3,maxLines:6,maxLength:2000,onChanged:(_)=>setState((){}),decoration:const InputDecoration(labelText:'Reason',hintText:'Briefly explain your leave request')),const SizedBox(height:12),
    ElevatedButton(onPressed:valid?()=>Navigator.pop(context,LeaveDraft(leaveTypeId:typeId!,startDate:start!,endDate:end!,reason:reason.text.trim())):null,child:const Text('Submit request')),
  ])));}
}
