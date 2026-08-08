class AppNotification {
  const AppNotification({required this.id,required this.type,required this.title,required this.message,required this.isRead,required this.createdAt,this.relatedEntityType,this.relatedEntityId});
  final String id,type,title,message; final bool isRead; final DateTime createdAt; final String? relatedEntityType,relatedEntityId;
  factory AppNotification.fromJson(Map<String,dynamic> j)=>AppNotification(id:j['id'] as String,type:j['type']?.toString()??'GENERAL',title:j['title']?.toString()??'Notification',message:j['message']?.toString()??'',isRead:j['isRead'] as bool? ?? false,createdAt:DateTime.parse(j['createdAt'] as String).toLocal(),relatedEntityType:j['relatedEntityType']?.toString(),relatedEntityId:j['relatedEntityId']?.toString());
}
class NotificationPageData{const NotificationPageData({this.items=const[],this.unreadCount=0});final List<AppNotification> items;final int unreadCount;}
