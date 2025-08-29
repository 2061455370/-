// 生物特征认证管理器
import { userAuth } from '@kit.UserAuthenticationKit';
import cryptoFramework from '@ohos.security.cryptoFramework';

class UserAuthManager {
  // 认证信任等级配置（ATL3为较高安全等级）
  private readonly authTrustLevel: userAuth.AuthTrustLevel = userAuth.AuthTrustLevel.ATL3;
  // 支持的认证类型列表
  private readonly authTypes: userAuth.UserAuthType[] = [
    userAuth.UserAuthType.PIN, // 锁屏密码认证
    userAuth.UserAuthType.FACE, // 面容识别
    userAuth.UserAuthType.FINGERPRINT// 指纹识别
  ];
  private readonly challengeLength = 32

  private title =  "身份验证"

  private cancelText = "取消"

  /**
   * 检查设备是否支持至少一种认证方式
   * @returns boolean 支持返回true，否则false
   */
  checkUserAuthSupport(): boolean {
    return this.authTypes.some((authType: userAuth.UserAuthType) => {
      try {
        // 检测单项认证能力
        userAuth.getAvailableStatus(authType, this.authTrustLevel);
        return true;
      } catch (error) {
        console.warn(`认证类型${authType}不支持:`, error);
        return false;
      }
    });
  }

  /**
   * 生成随机挑战值
   */
  private async getRandomValues(): Promise<Uint8Array> {
    try {
      const rand = cryptoFramework.createRandom();
      const dataBlob = await rand.generateRandom(32); // 生成32字节随机数

      // 关键转换：DataBlob -> Uint8Array
      return new Uint8Array(dataBlob.data);
    } catch (error) {
      console.error('生成随机数失败:', error);
      throw new Error('安全随机数生成失败');
    }
  }

  async authenticate(): Promise<Boolean> {
    if (!this.checkUserAuthSupport()) {
      throw new Error('设备不支持生物认证');
    }

    const challenge = await this.getRandomValues();
    const authInstance = userAuth.getUserAuthInstance({
      challenge: challenge,
      authType: this.authTypes,
      authTrustLevel: this.authTrustLevel
    }, {
      title: this.title,
      navigationButtonText: this.cancelText
    });

    return new Promise((resolve, reject) => {
      authInstance.on('result', {
        onResult(result) {
          if (result.result === userAuth.UserAuthResultCode.SUCCESS) {
            resolve(true);
          } else {
            reject(false);
          }
        }
      });

      authInstance.start();
    });
  }
}
export const userAuthManager = new UserAuthManager();
