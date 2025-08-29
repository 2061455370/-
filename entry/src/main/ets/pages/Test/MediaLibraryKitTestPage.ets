import { permissionManager } from '../../manager'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { dataSharePredicates } from '@kit.ArkData'
import Fetch from '@system.fetch'

@Entry
@Component
struct MediaLibraryKitTestPage {
  @State private isAuth: boolean = false
  @State private number: number = 0
  @State private photoAssets: photoAccessHelper.PhotoAsset[] = []
  @State private albumCoverUri: string = ""

  aboutToAppear() {
    this.requestPermissions()
  }

  async requestPermissions() {
    if (!permissionManager.checkAccessToken(['ohos.permission.READ_IMAGEVIDEO', 'ohos.permission.WRITE_IMAGEVIDEO'])) {
      this.isAuth = await permissionManager.requestPermissionsFromUser(['ohos.permission.READ_IMAGEVIDEO',
        'ohos.permission.WRITE_IMAGEVIDEO'])
    }
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          // 内容区域
          Text('图库权限是否获取：' + this.isAuth)
          Text('图库图片数量：' + this.number)
          Button("picker")
            .onClick(() => {
              let uris: Array<string> = []
              const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
              photoViewPicker.select()
                .then((photoSelectResult) => {
                  uris = photoSelectResult.photoUris;
                  console.info('fucking photoViewPicker.select to file succeed and uris are:' + uris);
                })
            })

          Button("test")
            .onClick(async () => {
              const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
              const fetchColumns = []
              const predicates = new dataSharePredicates.DataSharePredicates()
              const fetchResult = await phAccessHelper.getAssets({
                fetchColumns: fetchColumns,
                predicates: predicates
              })
              this.photoAssets = await fetchResult.getAllObjects()
              const firstAssets = await fetchResult.getFirstObject()
              photoAccessHelper.MediaAssetChangeRequest.deleteAssets(getContext(), [firstAssets])
              this.number = fetchResult.getCount()
            })

          Button("test album")
            .onClick(async () => {
              const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
              const predicats = new dataSharePredicates.DataSharePredicates()
              const fetchColumns = []
              const fetchResult = await phAccessHelper.getAlbums(photoAccessHelper.AlbumType.USER,
                photoAccessHelper.AlbumSubtype.USER_GENERIC,
                {
                  fetchColumns: fetchColumns,
                  predicates: predicats
                })

              const album = await fetchResult.getFirstObject()
              this.albumCoverUri = album.coverUri
            })


          Scroll() {
            Column() {
              Image(this.albumCoverUri)
                .width("100%")
              ForEach(this.photoAssets, (photoAsset: photoAccessHelper.PhotoAsset) => {
                Image(photoAsset.uri)
                  .height("100%")

              })
            }
          }.width("100%")
        }
        .constraintSize({ minHeight: '100%' })
        .width('100%')
        .height('100%')
      }
    }
    .title('Media Library Kit (媒体文件管理服务-图库)')
    .titleMode(NavigationTitleMode.Mini)
  }
}