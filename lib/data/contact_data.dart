import 'package:whatzapp/model/chat_model.dart';

ChatModel sourceChat = ChatModel(
  name: 'Yo',
  icon: 'person.svg',
  isGroup: false,
  time: '',
  currentMessage: '',
  status: 'Hey there!',
  select: false,
  id: 0,
);

List<ChatModel> chatModels = [
  ChatModel(
    name: 'Eduardo',
    icon: 'person.svg',
    isGroup: false,
    time: '18:04',
    currentMessage: 'Hi there',
    status: 'A full stack developer',
    select: false,
    id: 1,
  ),
  ChatModel(
    name: 'Marcos',
    icon: 'person.svg',
    isGroup: false,
    time: '18:04',
    currentMessage: 'hellouuu there',
    status: 'X developer',
    select: false,
    id: 2,
  ),
  ChatModel(
    name: 'Dadada',
    icon: 'person.svg',
    isGroup: false,
    time: '18:04',
    currentMessage: 'hellouuu there',
    status: 'Junior dev',
    select: false,
    id: 3,
  ),
  ChatModel(
    name: 'Malcom',
    icon: 'person.svg',
    isGroup: false,
    time: '18:04',
    currentMessage: 'klk cabeza',
    status: 'Frontend dev',
    select: false,
    id: 4,
  ),
];
