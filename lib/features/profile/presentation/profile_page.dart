import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../auth/application/session_controller.dart';
import '../../notifications/application/notification_controller.dart';
import '../application/profile_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  Future<void> _changePassword(BuildContext context,WidgetRef ref) async{
    final current=TextEditingController(), next=TextEditingController(), confirm=TextEditingController();
    final result=await showDialog<bool>(context:context,builder:(context)=>AlertDialog(title:const Text('Change password'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:current,obscureText:true,decoration:const InputDecoration(labelText:'Current password')),const SizedBox(height:10),TextField(controller:next,obscureText:true,decoration:const InputDecoration(labelText:'New password')),const SizedBox(height:10),TextField(controller:confirm,obscureText:true,decoration:const InputDecoration(labelText:'Confirm password'))]),actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Update'))]));
    if(result!=true)return;
    if(next.text.length<10||next.text!=confirm.text||!RegExp(r'[A-Z]').hasMatch(next.text)||!RegExp(r'[a-z]').hasMatch(next.text)||!RegExp(r'[0-9]').hasMatch(next.text)){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Passwords must match, be 10+ characters, and include upper/lowercase letters and a number.')));return;}
    try{await ref.read(sessionControllerProvider.notifier).changePassword(current.text,next.text);if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Password changed successfully.')));}catch(e){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}finally{current.dispose();next.dispose();confirm.dispose();}
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile=ref.watch(profileControllerProvider);
    return Scaffold(appBar:AppBar(title:const Text('Profile')),body:profile.when(loading:()=>const Center(child:CircularProgressIndicator()),error:(e,_)=>AppErrorView(message:e.toString(),onRetry:()=>ref.read(profileControllerProvider.notifier).refresh()),data:(user)=>RefreshIndicator(onRefresh:()=>ref.read(profileControllerProvider.notifier).refresh(),child:ListView(padding:const EdgeInsets.all(16),children:[
      AppCard(child:Column(children:[CircleAvatar(radius:34,backgroundColor:AppColors.primary.withValues(alpha: 0.10),child:Text(user.email.isEmpty?'E':user.email.substring(0,1).toUpperCase(),style:const TextStyle(fontSize:26,fontWeight:FontWeight.w800,color:AppColors.primary))),const SizedBox(height:12),Text(user.email,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w700)),const SizedBox(height:5),Text(user.roles.join(' • '),style:const TextStyle(color:AppColors.textSecondary))])),
      const SizedBox(height:16),AppCard(child:Column(children:[_item(Icons.badge_outlined,'Account ID',user.id),const Divider(),_item(Icons.shield_outlined,'Role',user.roles.join(', ')),const Divider(),_item(Icons.lock_outline_rounded,'Access','${user.permissions.length} permissions')])) ,
      const SizedBox(height:16),OutlinedButton.icon(onPressed:()=>_changePassword(context,ref),icon:const Icon(Icons.password_rounded),label:const Text('Change password')),const SizedBox(height:10),FilledButton.tonalIcon(onPressed:() async { await ref.read(pushNotificationServiceProvider).unregister(); await ref.read(sessionControllerProvider.notifier).logout(); },icon:const Icon(Icons.logout_rounded),label:const Text('Sign out')),
    ]))));
  }
}
Widget _item(IconData icon,String label,String value)=>ListTile(contentPadding:EdgeInsets.zero,leading:Icon(icon,color:AppColors.primary),title:Text(label),subtitle:Text(value));
