import 'package:whatzapp/model/chat_model.dart';

ChatModel sourceChat = ChatModel(
  name: 'Yo',
  icon: 'person.svg',
  isGroup: false,
  time: '',
  currentMessage: '',
  status: 'Hey there!',
  id: 0,
  uid: 'my_uid',
);

List<ChatModel> chatModels = [
  ChatModel(
    name: 'Eduardo',
    icon: 'person.svg',
    isGroup: false,
    time: '18:04',
    currentMessage: 'Hi there',
    status: 'A full stack developer',
    id: 1,
    uid: 'uid_1',
  ),
  ChatModel(
    name: 'Marcos',
    icon: 'person.svg',
    isGroup: false,
    time: '18:04',
    currentMessage: 'hellouuu there',
    status: 'X developer',
    id: 2,
    uid: 'uid_2',
  ),
  ChatModel(
    name: 'Dadada',
    icon: 'person.svg',
    isGroup: false,
    time: '18:04',
    currentMessage: 'hellouuu there',
    status: 'Junior dev',
    id: 3,
    uid: 'uid_3',
  ),
  ChatModel(
    name: 'Malcom',
    icon: 'person.svg',
    isGroup: false,
    time: '18:04',
    currentMessage: 'klk cabeza',
    status: 'Frontend dev',
    id: 4,
    uid: 'uid_4',
  ),
];