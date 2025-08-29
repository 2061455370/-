import { CryptoJS } from "@ohos/crypto-js"

export function encryMD5(str: string): string {
  return CryptoJS.MD5(str).toString()
}
