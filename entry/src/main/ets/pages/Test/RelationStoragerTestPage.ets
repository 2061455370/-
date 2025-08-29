import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { JSON } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { privacyNoteDB, PrivacyNoteDBInfo } from '../../database/PrivacyNoteDB';


interface privacyNode extends ValuesBucket {
  id: number | null,
  title: string,
  content: string,
  created_at: number | null
}

@Entry
@Component
struct RelationStoragerTestPage {
  private tableName: string = "privacyNotes.db"
  private createTableSql: string = `CREATE TABLE IF NOT EXISTS ${this.tableName} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)`
  private storage: relationalStore.RdbStore | null = null

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {

          Button("创建连接数据库")
            .onClick(async () => {
              relationalStore.getRdbStore(getContext(), {
                name: this.tableName,
                securityLevel: relationalStore.SecurityLevel.S1
              }, (err, rdbStore) => {
                if (err) {
                  console.error("fucking Failed to get RdbStore:", err);
                  return;
                } else {
                  this.storage = rdbStore
                  rdbStore.execute(this.createTableSql)
                }
              });
            })

          Button("插入数据")
            .onClick(async () => {
              const test = await privacyNoteDB.insert({
                id: null,
                title: "tes12t",
                content: "test323",
                updated_at: null
              } as PrivacyNoteDBInfo)
              console.log("fucking " + test)
            })


          Button("查询数据")
            .onClick(async () => {
              const rdbPredicates = new relationalStore.RdbPredicates("privacyNotes.db")
              await this.storage?.query(rdbPredicates, (err, resultSet) => {
                if (err) {
                  promptAction.showToast({ message: "fucking" + err })
                } else {
                  promptAction.showToast({ message: "行数： " + resultSet?.rowCount })

                }
              })


            })


        }
        .width('100%')
        .height('100%')

      }
    }
    .title('权限学习')
    .titleMode(NavigationTitleMode.Mini)
  }
}