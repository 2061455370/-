import { PRIVACY_QUESTION_LIST, PRIVACY_SETTINGS, PrivacySettings } from '../../../common/constants'
import { encryMD5 } from '../../../common/utils/encryptMD5'
import { Router } from '@ohos.arkui.UIContext'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct ForgetPasswordPage {
  // 获取 AppStorage 的数据
  @StorageLink(PRIVACY_SETTINGS) privacySettings: PrivacySettings = {}
  // 输入的答案
  @State answerText: string = ''
  // 错误提示语
  @State errorMessage: string = ''
  // 空状态，输入框抖动效果
  @State inputPaddingLeft: number = 10

  submit() {
    if (encryMD5(this.answerText) !== this.privacySettings.protectQuestionAnswer) {
      this.errorMessage = "密码错误"
    } else {
      router.replace({ url: 'pages/Privacy/PrivacyIndexPage' })
    }
  }

  @Builder
  NavigationMenus() {
    Row() {
      Text('下一步')
        .fontSize(16)
        .fontColor($r('app.color.font'))
        .onClick(() => {
          // TODO：下一步
          this.submit()
        })
    }
    .height('100%')
    .padding({ right: 25 })
  }

  build() {
    Navigation() {

      Column() {
        Text('重置密码')
          .fontSize(16)
          .fontColor($r('app.color.font'))
        Text(this.errorMessage ? this.errorMessage : '请回答密码保护问题')
          .fontSize(12)
          .fontColor(this.errorMessage ? $r('app.color.danger') : $r('app.color.font_sub'))
          .lineHeight(25)
        Column() {
          Text(this.privacySettings.protectQuestionIndex !== undefined ?
          PRIVACY_QUESTION_LIST[this.privacySettings.protectQuestionIndex].value : "你还未设置密保问题")
            .fontSize(16)
            .fontWeight(500)
            .fontColor('#182431')
            .width('100%')
            .padding({ left: 10 })
            .height(56)
            .border({ width: { bottom: 1 }, color: $r('app.color.border'), radius: 0 })
          Row() {
            TextInput({ placeholder: '密保问题答案', text: this.answerText })
              .cancelButton({
                style: CancelButtonStyle.INPUT, // 输入时显示清空按钮
                icon: { src: $r('app.media.ic_public_cancel_button') }  // 设置右侧清除按钮样式
              })
              .defaultFocus(true)// 自动获取焦点
              .backgroundColor(Color.Transparent)
              .padding(0)
              .width('100%')
              .height(56)
              .onChange((text) => {
                this.answerText = text
              })
              .onSubmit(() => {
                // TODO：提交密保问题答案
                this.submit()
              })
          }
          .border({ width: { bottom: 1 }, color: $r('app.color.border'), radius: 0 })
          .padding({ left: this.inputPaddingLeft })
          .animation({
            duration: 400,
            tempo: 4,
            iterations: 2,
            curve: Curve.Linear,
            onFinish: () => {
              // 动画结束，恢复默认值
              this.inputPaddingLeft = 10
            }
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
        .margin({ top: 20 })
      }
      .padding({ top: 140 })
    }
    .title('隐私空间')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .menus(this.NavigationMenus)
  }
}