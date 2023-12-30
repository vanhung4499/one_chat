import 'dart:io';

import 'package:isar/isar.dart';

part 'session_repository.g.dart';

@collection
class SessionTable {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String sid = '';

  String? name;
  String? promptContent;

  @Index(composite: [CompositeIndex('status'), CompositeIndex('updated')])
  String type = 'chatgpt'; // chatgpt / bard

  @Index(composite: [CompositeIndex('status'), CompositeIndex('updated')])
  String modelType = 'chat'; // chat / text / image

  String model = 'gpt-3.5-turbo';
  int? maxContextSize;
  int? maxContextMsgCount;
  double? temperature;
  int? maxTokens;
  bool synced = false;

  @Index(composite: [CompositeIndex('updated')])
  int status = 1; // 1 = show, 0 = delete
  int? updated; // Last updated YYYYMMDDHHmmssSSS
}

@collection
class MessageTable {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String? mid;

  @Index(composite: [CompositeIndex('status')])
  String? sid;

  String? model;
  String? role;
  String? content;
  int? updated; // Last updated YYYYMMDDHHmmssSSS
  // bool? generating;
  // String msgType = 'new'; // new, refresh
  bool synced = false;
  List<String>? quotes;

  /// post json
  String? postJson;
  List<String>? imageUrls;

  /// response json
  String? responseJson;

  @Index()
  int status = 1; // 1 = show, 0 = delete
}

class SessionRepository {
  late Directory dir;
  late Isar isar;

  SessionRepository(this.dir) {
    isar = Isar.openSync(
      [SessionTableSchema, MessageTableSchema],
      directory: dir.path,
    );
  }

  int save(SessionTable session) {
    SessionTable? st = findBySessionId(session.sid);
    SessionTable st2 = session;
    if (st != null) {
      st2.id = st.id;
    }
    // print(st2.updated);
    return isar.writeTxnSync(() => isar.sessionTables.putSync(st2));
  }

  List<SessionTable> findAll(int status) {
    List<SessionTable> chatList;
    chatList = isar.sessionTables
        .where()
        .statusEqualToAnyUpdated(status)
        .sortByUpdatedDesc()
        .findAllSync();
    return chatList;
  }

  // ignore: provide_deprecation_message
  @deprecated
  void remove(String sid) {
    removeSession(sid);
  }

  void removeSession(String sid) {
    SessionTable? st = findBySessionId(sid);
    if (st != null) {
      st.status = 0;
      save(st);
    }
  }

  void removeMessage(String msgId) {
    MessageTable? msg = findMessageByMid(msgId);
    if (msg != null) {
      msg.status = 0;
      saveMessage(msg);
    }
  }

  SessionTable? findBySessionId(String sid) {
    SessionTable? st;
    st = isar.sessionTables.where().sidEqualTo(sid).findFirstSync();
    return st;
  }

  SessionTable? findFirst() {
    SessionTable? st;
    st = isar.sessionTables.where().statusEqualToAnyUpdated(1).findFirstSync();
    return st;
  }

  bool isExist(String sid) {
    int count = isar.sessionTables.where().sidEqualTo(sid).countSync();
    if (count > 0) {
      return true;
    }
    return false;
  }

  List<MessageTable> findMessagesBySessionId(String? sid, int status) {
    List<MessageTable> messageList;
    messageList = isar.messageTables
        .where()
        .sidStatusEqualTo(sid, status)
        .sortByUpdatedDesc()
        .findAllSync();
    return messageList;
  }

  List<MessageTable> findAllMessages(int status) {
    List<MessageTable> messageList;
    messageList = isar.messageTables
        .where()
        .statusEqualTo(status)
        .sortByUpdated()
        .findAllSync();
    return messageList;
  }

  MessageTable? findMessageByMid(String? mid) {
    MessageTable? mt;
    mt = isar.messageTables.where().midEqualTo(mid).findFirstSync();
    return mt;
  }

  int saveMessage(MessageTable mt) {
    MessageTable? mtInDb = findMessageByMid(mt.mid);
    MessageTable savedmt = mt;
    if (mtInDb != null && mtInDb.id > 0) {
      savedmt.id = mtInDb.id;
    }
    return isar.writeTxnSync(() => isar.messageTables.putSync(savedmt));
  }
}