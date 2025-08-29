// xxx.ets
@Entry
@Component
struct PatternLockExample {
  @State passwords: number[] = [] // 存储第一次输入的密码
  @State message: string = 'Please input password!' // 提示信息
  private patternLockController: PatternLockController = new PatternLockController()

  build() {
    Column() {
      Text(this.message)
        .textAlign(TextAlign.Center)
        .margin(20)
        .fontSize(20)

      PatternLock(this.patternLockController)
        .sideLength(200) // 组件边长
        .circleRadius(9) // 圆点半径
        .pathStrokeWidth(18) // 路径线条宽度
        .activeColor('#B0C4DE') // 激活状态颜色
        .selectedColor('#228B22') // 选中状态颜色
        .pathColor('#90EE90') // 路径颜色
        .backgroundColor('#F5F5F5') // 背景色
        .autoReset(true) // 自动重置
        .onDotConnect((index: number) => {
          console.log("onDotConnect index: " + index)
        })
        .onPatternComplete((input: Array<number>) => {
          // 校验密码长度是否合法
          if (input == null || input == undefined || input.length < 5) {
            this.message = 'Password length must be at least 5 dots!'
            this.patternLockController.reset() // 重置组件
            return
          }

          // 判断是否为第二次输入
          if (this.passwords.length > 0) {
            // 验证两次输入是否一致
            if (this.passwords.toString() === input.toString()) {
              this.message = 'Password set successfully: ' + this.passwords.toString()
              this.patternLockController.setChallengeResult(PatternLockChallengeResult.CORRECT)
            } else {
              this.message = 'Passwords do not match, try again!'
              this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG)
            }
            this.passwords = [] // 清空缓存
          } else {
            // 提示第二次输入
            this.passwords = input
            this.message = 'Please confirm your password.'
          }
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}