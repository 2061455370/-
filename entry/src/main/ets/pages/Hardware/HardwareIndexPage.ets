import { NavigationTitleBuilder } from '../../common/builders';
import { SENSOR_NAME_LIST, SensorName } from '../../common/constants';
import { themeManager } from '../../manager';
import { deviceInfo } from '@kit.BasicServicesKit';
import { process } from '@kit.ArkTS';
import dayjs from 'dayjs'
import duration from 'dayjs/plugin/duration'
import { connection } from '@kit.NetworkKit';
import { display } from '@kit.ArkUI';
import { sensor, Sensor } from '@kit.SensorServiceKit';

@Entry
@Component
struct HardwareIndexPage {
  private display = display.getDefaultDisplaySync();
  // 同步初始化的属性
  @State marketName: string = deviceInfo.marketName;
  @State osFullName: string = deviceInfo.osFullName;
  @State sdkApiVersion: string = deviceInfo.sdkApiVersion.toString();
  @State deviceType: string = deviceInfo.deviceType;
  @State uptime: number = process.uptime();
  @State displayHeight: number = this.display.height;
  @State displayWidth: number = this.display.width;
  @State displayRefreshRate: number = this.display.refreshRate;
  @State displayDensityDPI: number = this.display.densityDPI;
  // 需要异步初始化的属性（先赋空值）
  @State netBearType: string = '';
  @State IPAddress: string = '';
  @State subnetMask: string = '';
  @State broadcastAddress: string = '';
  @State supportSensorIds: number[] = [];

  async aboutToAppear() {
    // 初始化 dayjs 插件
    dayjs.extend(duration);

    // 并行初始化所有异步属性
    await Promise.all([
      this.initNetworkInfo(),
      this.initSensorIds()
    ]);
  }

  private async initNetworkInfo() {
    try {
      // 网络类型
      this.netBearType = await this.getNetBearType();

      // IP 地址
      this.IPAddress = this.getNetAddress();

      // 子网掩码
      this.subnetMask = await this.getSubnetMask();

      // 广播地址（依赖 IP 和子网掩码）
      this.broadcastAddress = this.getBroadcastAddress();
    } catch (err) {
      console.error(`初始化网络信息失败: ${err}`);
    }
  }

  private async initSensorIds() {
    try {
      this.supportSensorIds = await this.getSensorIds();
    } catch (err) {
      console.error(`获取传感器列表失败: ${err}`);
      this.supportSensorIds = [];
    }
  }

  private async getSensorIds(): Promise<number[]> {
    const sensorList = await sensor.getSensorListSync();
    return sensorList.map(item => item.sensorId);
  }

  private async getSubnetMask(): Promise<string> {
    const props = await connection.getConnectionPropertiesSync(connection.getDefaultNetSync());
    const linkAddress = props.linkAddresses[0];
    let prefixLength = linkAddress.prefixLength;

    const mask: number[] = [];
    for (let i = 0; i < 4; i++) {
      const bits = Math.min(prefixLength, 8);
      mask.push(256 - Math.pow(2, 8 - bits));
      prefixLength -= bits;
    }
    return mask.join('.');
  }

  private getBroadcastAddress(): string {
    if (!this.IPAddress || !this.subnetMask) {
      return '';
    }

    const ipParts = this.IPAddress.split('.').map(Number);
    const mask = this.subnetMask.split('.').map(Number);

    const broadcast: number[] = [];
    for (let i = 0; i < 4; i++) {
      broadcast.push(ipParts[i] | (~mask[i] & 0xFF));
    }
    return broadcast.join('.');
  }

  private getNetAddress(): string {
    const linkAddresses = connection.getConnectionPropertiesSync(connection.getDefaultNetSync()).linkAddresses;
    return linkAddresses?.[0]?.address?.address || "未配置IP";
  }

  private async getNetBearType(): Promise<string> {
    if (!await connection.hasDefaultNetSync()) {
      return '无网络';
    }

    const bearerTypes = (await connection.getNetCapabilitiesSync(connection.getDefaultNetSync())).bearerTypes;

    if (bearerTypes.includes(connection.NetBearType.BEARER_ETHERNET)) {
      return '以太网网络';
    } else if (bearerTypes.includes(connection.NetBearType.BEARER_WIFI)) {
      return 'Wi-Fi网络';
    } else if (bearerTypes.includes(connection.NetBearType.BEARER_VPN)) {
      return 'VPN网络';
    } else if (bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR)) {
      return '蜂窝网络';
    } else if (bearerTypes.includes(connection.NetBearType.BEARER_BLUETOOTH)) {
      return '蓝牙网络';
    } else {
      return '未知网络';
    }
  }

  formatToDateTime(second: number): string {
    return dayjs().subtract(second, 'second').format('YYYY-MM-DD hh:mm:ss')
  }

  formatToDutation(second: number): string {
    return dayjs.duration(second, 'second').format("D天H小时mm分")
  }

  onPageShow() {
    themeManager.settingStatusBarWhite()
  }

  onPageHide() {
    themeManager.settingStatusBarBlack()
  }

  @Builder
  ListTitle(title: string) {
    Text(title)
      .fontSize(16)
      .fontWeight(500)
      .fontColor($r('app.color.font'))
      .width('100%')
      .padding({
        left: 20,
        right: 20,
        top: 20,
        bottom: 10
      })
      .backgroundColor($r('app.color.white'))
  }

  build() {
    Navigation() {
      // 顶部硬件信息
      Column({ space: 20 }) {
        Text(this.marketName)
          .fontSize(16)
          .fontColor($r('app.color.white'))
        Column({ space: 10 }) {
          Text('系统版本：' + this.osFullName)
            .fontSize(12)
            .fontColor($r('app.color.white'))
          Text('API 版本：' + this.sdkApiVersion)
            .fontSize(12)
            .fontColor($r('app.color.white'))
          Text('设备类型：' + this.deviceType)
            .fontSize(12)
            .fontColor($r('app.color.white'))
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({
        left: 20,
        right: 20,
        top: 30,
        bottom: 30
      })
      .alignItems(HorizontalAlign.Start)

      // 其他内容
      Column() {
        List() {
          ListItemGroup({ header: this.ListTitle('基本信息') }) {
            ListRow({ title: '上次启动', value: this.formatToDateTime(this.uptime) })
            ListRow({ title: '运行时间', value: this.formatToDutation(this.uptime) })
          }

          ListItemGroup({ header: this.ListTitle('网络信息') }) {
            ListRow({ title: '网络类型', value: this.netBearType })
            ListRow({ title: 'IP地址', value: this.IPAddress })
            ListRow({ title: '子网掩码', value: this.subnetMask })
            ListRow({ title: '广播地址', value: this.broadcastAddress })
          }

          ListItemGroup({ header: this.ListTitle('硬件特性') }) {
            // 屏幕信息
            ListRow({ title: '屏幕分辨率（像素）', value: `${this.displayHeight}x${this.displayWidth}` })
            ListRow({ title: '屏幕刷新率（Hz）', value: this.displayRefreshRate })
            ListRow({ title: '像素密度（PPI）', value: this.displayDensityDPI })
            // 传感器信息
            ForEach(SENSOR_NAME_LIST, (item: SensorName) => {
              ListRow({
                title: item.sensorName,
                value: this.supportSensorIds.includes(item.sensorId) ? '有' : '-'
              })
            })
          }
        }
        .divider({ strokeWidth: 10 })
        .sticky(StickyStyle.Header)
        .height('100%')
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor($r('app.color.white'))
      .borderRadius({ topLeft: 12, topRight: 12 })
      .clip(true)
    }
    .title(NavigationTitleBuilder('硬件信息'))
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .hideBackButton(true)
    .linearGradient({
      angle: 180,
      colors: [[$r('app.color.brand'), 0], [$r('app.color.brand_light'), 0.4], [$r('app.color.white'), 0.4]]
    })
  }
}

@Component
struct ListRow {
  @Prop title: string = ''
  @Prop value: string | number = ''

  build() {
    Row() {
      Text(this.title)
        .fontSize(14)
        .fontColor($r('app.color.font'))
      Text(this.value.toString())
        .fontSize(12)
        .fontColor($r('app.color.font_sub'))
    }
    .padding({ left: 20, right: 20 })
    .height(40)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}


