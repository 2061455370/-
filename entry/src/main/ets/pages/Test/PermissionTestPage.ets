import { abilityAccessCtrl, bundleManager, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit'
import { JSON } from '@kit.ArkTS'

async function checkAccessToken() {
  const atManage = abilityAccessCtrl.createAtManager();
  const bundleInfo =
    await bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
  const tokenId = bundleInfo.appInfo.accessTokenId;

  const status = atManage.checkAccessTokenSync(tokenId, "ohos.permission.READ_CALENDAR");
  AlertDialog.show({ message: JSON.stringify(status, null, 2) });
}

async function requestPermissionsFromUser(permissionList: Permissions[]): Promise<PermissionRequestResult> {
  const atManage = abilityAccessCtrl.createAtManager();
  return await atManage.requestPermissionsFromUser(getContext(), permissionList);
}

async function requestPermissionOnSetting(permissionList: Permissions[]) {
  const atManage = abilityAccessCtrl.createAtManager();
  const context = getContext() as common.UIAbilityContext;
  await atManage.requestPermissionOnSetting(
    context, permissionList
  );
}

@Entry
@Component
struct PermissionTestPage {
  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button("检测权限")
            .onClick(() => {
              checkAccessToken();
            })
            .constraintSize({
              minHeight: '20%'
            });

          Button("动态获取权限")
            .onClick(async () => {
              const permissionRequestResult =
                await requestPermissionsFromUser(['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR']);
              AlertDialog.show({ message: JSON.stringify(permissionRequestResult, null, 2) });
            })
            .constraintSize({
              minHeight: '20%'
            });
          Button("打开系统设置")
            .onClick(async () => {
              await requestPermissionOnSetting(['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR']);
            })
            .constraintSize({
              minHeight: '20%'
            });
        }
        .width('100%')
        .height('100%')

      }
    }
    .title('权限学习')
    .titleMode(NavigationTitleMode.Mini)
  }
}