import { PRIVACY_SETTINGS, PrivacySettings } from '../../../common/constants'
import { router } from '@kit.ArkUI'
import { encryMD5 } from '../../../common/utils/encryptMD5'

interface RouterParams {
  isForgetPassword?: boolean
}

@Entry
@Component
struct AuthPatternLockSettingsPage {
  // 获取隐私空间设置
  @StorageLink(PRIVACY_SETTINGS) privacySettings: PrivacySettings = {}
  // 正在输入的图形密码
  @State inputPassword: number[] = []
  // 第一次输入的密码
  @State firstPassword: number[] = []
  // 错误提示语
  @State errorMessage: string = ''
  // 路由参数
  @State routerParams: RouterParams = {}
  // 定时器，用于清空提示文案
  private timeoutID: number = -1
  // 控制器
  private patternLockController: PatternLockController = new PatternLockController()

  patternComplete(input: number[]) {
    if (input.length < 4) {
      this.errorMessage = "请最少连接4个点"
      this.inputPassword = input
    } else if (this.privacySettings.patternPassword === encryMD5(input.toString())) {
      this.errorMessage = "请不要输入相同的密码"
      this.inputPassword = input
    } else {
      this.errorMessage = ""
      if (this.firstPassword.length === 0) {
        this.firstPassword = input
      } else {
        if (this.firstPassword.toString() === input.toString()) {
          this.privacySettings.patternPassword = encryMD5(input.toString())
          router.back({ url: 'pages/Privacy/PrivacyIndexPage' })
          // router.pushUrl({
          //   url: 'pages/Index'
          // })
          // router.clear()
        } else {
          this.errorMessage = "两次输入的密码不一样 请重新输入"
          this.inputPassword = input
        }
      }
    }
    setTimeout(() => {
      this.patternLockController.reset()
      this.inputPassword = []
    }, 200)
  }

  build() {
    Navigation() {
      // Column() {
      //   Text('inputPasswords：' + this.inputPassword)
      //   Text('firstPasswords：' + this.firstPassword)
      // }
      Column({ space: 20 }) {
        Column({ space: 10 }) {
          // 请输入密码
          Text(this.firstPassword.length === 0 ? '设置手势密码' : '再次确认手势密码')
            .fontSize(16)
            .fontColor($r('app.color.font'))
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(12)
              .fontColor($r('app.color.danger'))
          } else {
            Text(this.firstPassword.length === 0 ? '请绘制手势密码，至少链接4个点' : '请再次输入确认手势密码')
              .fontSize(12)
              .fontColor($r('app.color.font_sub'))
          }
        }

        PatternLock(this.patternLockController)
          .sideLength(320)// 宽高
          .circleRadius(12)// 圆点半径
          .pathStrokeWidth(10)// 线宽度
          .regularColor('#d9d9d9')// 未选中圆点色
          .activeColor('#800a59f7')// 经过圆点色
          .selectedColor(this.errorMessage && this.inputPassword.length !== 0 ? '#ffff5e5d' : '#ff0a59f7')// 选中圆点色
          .pathColor(this.errorMessage && this.inputPassword.length !== 0 ? '#ccff5e5d' : '#cc0a59f7')// 线颜色
          .onDotConnect(() => {
            // 密码输入选中宫格圆点时触发该回调
            clearTimeout(this.timeoutID)
          })
          .onPatternComplete((input: number[]) => {
            // TODO：密码输入结束时触发该回调
            this.patternComplete(input)
          })
      }
      .padding({ top: 140 })
    }
    .title('隐私空间')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
  }
}