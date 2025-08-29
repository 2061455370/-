import { Permissions } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { dataSharePredicates } from '@kit.ArkData';
import { permissionManager } from '.';
import { promptAction } from '@kit.ArkUI';
import image from '@ohos.multimedia.image';
import { fileIo } from '@kit.CoreFileKit';
import { KILO_BYTE } from '../common/utils';
import fs from '@ohos.file.fs';

class ClearManager {
  // 权限
  private permissions: Permissions[] = ["ohos.permission.READ_IMAGEVIDEO", "ohos.permission.WRITE_IMAGEVIDEO"];
  // 图片资源
  private photoAssets: photoAccessHelper.PhotoAsset[] = [];
  // 图片字段
  private fetchColumns: photoAccessHelper.PhotoKeys[] = [
    photoAccessHelper.PhotoKeys.DATE_ADDED,
    photoAccessHelper.PhotoKeys.SIZE,// 图片文件大小
  ];

  // 图片权限
  async requestPermissions() {
    try {
      // 申请权限
      await permissionManager.requestPermissionsFromUser(this.permissions);
    } catch {
      // 未开启弹窗提示
      const dialogRes = await promptAction.showDialog({
        alignment: DialogAlignment.Center,
        title: '温馨提示',
        message: '手机瘦身功能需要获取权限，请在系统设置中打开相册开关',
        buttons: [
          { text: '取消', color: $r('app.color.font_sub') },
          { text: '立即开启', color: $r('app.color.brand') }
        ]
      });
      // 打开设置页
      if (dialogRes.index == 1) {
        permissionManager.requestPermissionOnSetting(this.permissions);
      }
    }
  }

  // 获取图片资源
  async getAccess() {
    const predicates = new dataSharePredicates.DataSharePredicates();
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext());
    const fetchResult = await phAccessHelper.getAssets({
      fetchColumns: this.fetchColumns,
      predicates: predicates
    });
    this.photoAssets = await fetchResult.getAllObjects();
    return this.photoAssets;
  }

  // 获取屏幕截图
  async getScreenshotList() {
    await this.getAccess()
    return this.photoAssets.filter(item => item.displayName.toLowerCase().includes("screenshot"))
  }

  // 获取视频
  async getVideoList() {
    await this.getAccess()
    return this.photoAssets.filter(item => item.photoType === photoAccessHelper.PhotoType.VIDEO)
  }

  // 获取大图片
  async getLargerIamge() {
    await this.getAccess()
    return this.photoAssets.filter((item) => item.get(photoAccessHelper.PhotoKeys.SIZE) > 2 * KILO_BYTE * KILO_BYTE)
  }

  async deleteImage(uris: string[]) {
    await photoAccessHelper.MediaAssetChangeRequest.deleteAssets(getContext(), uris)
    // uris.forEach(async (uri) => {
    //
    //   console.log()
    // })

  }

  async compressImage(uris: string[]) {
    const imagePacker = image.createImagePacker()
    uris.forEach(async (uri) => {
      let f = fileIo.openSync(uri)
      const imageSource = image.createImageSource(f.fd)
      const arrayBuffer = await imagePacker.packing(imageSource, { format: "image/jpeg", quality: 70 })
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
      uri = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg')
      f = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE)
      fileIo.writeSync(f.fd, arrayBuffer)
      fileIo.close(f)
    })
  }
}

export const clearManager = new ClearManager()