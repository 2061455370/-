import { userAuth } from '@kit.UserAuthenticationKit'
import { promptAction } from '@kit.ArkUI'
import { JSON } from '@kit.ArkTS'
import { userAuthManager } from '../../manager'


@Entry
@Component
struct PermissionTestPage {
  build() {
    Navigation() {
      Column({ space: 10 }) {
        Button('查询支持的认证能力')
          .onClick(() => {
            try {
              userAuth.getAvailableStatus(
                userAuth.UserAuthType.PIN,
                userAuth.AuthTrustLevel.ATL1
              );
              promptAction.showToast({
                message: '当前设备支持PIN认证能力'
              });
            } catch (error) {
              AlertDialog.show({
                message: JSON.stringify(error, null, 2)
              });
            }
          })
        Button("调取认证")
          .onClick(() => {
            userAuthManager.authenticate()
          })
        Button("获取认证结果")
          .onClick(() => {
            AlertDialog.show({ message: JSON.stringify(userAuthManager.checkUserAuthSupport(), null, 2) })
          })
      }
    }
    .title('测试页入口')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
  }
}