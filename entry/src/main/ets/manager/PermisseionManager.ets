import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit'

class PermissionManager {
  checkAccessToken(permissions: Permissions[]): boolean {
    try {
      const atManage = abilityAccessCtrl.createAtManager();
      const bundleInfo = bundleManager.getBundleInfoForSelfSync(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
      );
      const tokenId = bundleInfo.appInfo.accessTokenId;

      return permissions.every(permission => {
        return atManage.checkAccessTokenSync(tokenId, permission) ===
        abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
      }

      );
    } catch (error) {
      console.error('fucking check error:', error);
      return false;
    }
  }

  async requestPermissionsFromUser(permissionList: Permissions[]): Promise<boolean> {
    const atManage = abilityAccessCtrl.createAtManager();
    const permissionRequestResult = await atManage.requestPermissionsFromUser(getContext(), permissionList);

    // 调试日志
    console.log("fucking Permission request result:", JSON.stringify(permissionRequestResult));

    // 检查每个权限是否被授予
    const allGranted = permissionList.every((permission, index) => {
      const status = permissionRequestResult.authResults[index];
      const isGranted = status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;

      if (!isGranted) {
        console.warn(`fucking Permission ${permission} not granted, status: ${status}`);
      }

      return isGranted;
    });

    return allGranted;
  }

  // 跳转到设置页面请求权限
  async requestPermissionOnSetting(permissionList: Permissions[]) {
    try {
      const atManage = abilityAccessCtrl.createAtManager();
      const context = getContext() as common.UIAbilityContext;
      await atManage.requestPermissionOnSetting(context, permissionList);
    } catch (error) {
      console.error('fucking setting:', error);
    }
  }


}

export const permissionManager = new PermissionManager();