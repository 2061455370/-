import { relationalStore, ValuesBucket } from '@kit.ArkData'

// 隐私笔记的类型
export interface PrivacyNoteDBInfo extends ValuesBucket {
  id: number | null // 新增时 id 设置为 null，可实现 id 自增
  title: string
  content: string
  updated_at: number | null
}

// 隐私笔记数据库封装
class PrivacyNoteDB {
  // 操作数据库的实例
  private store: relationalStore.RdbStore | null = null
  // 数据库表名
  private tableName = 'privacy_note'
  // 创建数据库的语句
  private sqlCreate = `CREATE TABLE IF NOT EXISTS ${this.tableName} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)`

  constructor() {
    this.getStoreInstance().then((store) => {
      store.executeSql(this.sqlCreate)
    })
  }

  // 获取数据库操作的实例
  async getStoreInstance() {
    // 如果数据库实例已存在，直接返回，没有才创建实例
    if (this.store) {
      return this.store
    }
    // 获取操作数据库的实例
    this.store = await relationalStore.getRdbStore(getContext(), {
      name: this.tableName + '.db', // 数据库名称
      securityLevel: relationalStore.SecurityLevel.S1 // 安全等级
    });
    return this.store
  }

  async insert(privacyNoteDBInfo: PrivacyNoteDBInfo) {
    return await this.store?.insert(this.tableName, privacyNoteDBInfo, (err) => {
      if (err) {
        console.log("fucking err" + err);
      }
    })
  }

  async delete(predicates: relationalStore.RdbPredicates) {
    return await this.store?.delete(predicates)
  }

  async update(privacyNoteInfo: PrivacyNoteDBInfo, predicates: relationalStore.RdbPredicates) {
    return await this.store?.update(privacyNoteInfo, predicates)
  }

  async query(predicates: relationalStore.RdbPredicates) {
    return await this.store?.query(predicates)
  }
}

export const privacyNoteDB = new PrivacyNoteDB()
