# I.A.R. 80-B  
  
![iar80b](../images/iar80b.png)  
  
## 描述  
  
飞行构型的失速指示空速：151~162 km/h  
起降构型的失速指示空速：143~151 km/h  
俯冲极速：750 km/h  
最大过载：12 G  
飞行构型失速迎角：16.0°  
着陆构型失速迎角：13.8°  
  
最大真空速，高度海平面，发动机模式——应急：447 km/h  
最大真空速，高度3800m，发动机模式——应急：511 km/h  
  
最大真空速，高度海平面，发动机模式——战斗：427 km/h  
最大真空速，高度4700m，发动机模式——战斗：505 km/h  
  
  
实用升限：10500 m  
海平面爬升率：13.9 m/s  
3000m时爬升率：13.1 m/s  
6000m时爬升率：9.4 m/s  
  
海平面最大性能盘旋时间：17.8 s，指示空速 300 km/h。  
  
3000m（9843 feet）时续航时间：1.9h，指示空速 350 km/h。  
  
起飞速度：150~180 km/h  
进近速度：200~220 km/h  
着陆速度：170~180 km/h  
着陆迎角：14.2°  
  
注1：所提供的数据适用于国际标准大气（ISA）。  
注2：飞行性能范围基于可能的飞机质量范围。  
注3：极速、爬升率和盘旋时间基于标准飞机质量。  
注4：爬升率基于战斗动力，盘旋时间基于应急动力。  
  
发动机：  
型号：I.A.R. 14 K. IV. C-32  
Maximum power in Emergency mode at sea level: 1050 HP  
Maximum power in Emergency mode at 2700 m: 1100 HP  
Maximum power in Nominal mode at sea level: 930 HP  
Maximum power in Nominal mode at 3200 m: 1000 HP  
  
发动机模式：  
Nominal (unlimited time): 2300 RPM, 850 mm Hg  
Emergency (up to 3 minutes): 2300 RPM, 935 mm Hg  
  
发动机滑油出油口额定油温：40~110 °C  
发动机滑油出油口最高油温：120 °C  
  
空重：2093 kg  
最小重量（无弹药、10%燃油）：2522 kg  
标准重量：2745 kg  
最大起飞重量：3030 kg  
燃油载荷：324 kg / 450 L  
有效载荷：1050 kg  
  
前射武器：  
4 x 7.92mm machine gun "FN Browning 7.92 mod 1938", 1600 rounds, 1500 rounds per minute, wing-mounted  
2 x 13.2mm machine gun "FN Browning 13.2", 350 rounds, 1080 rounds per minute, wing-mounted  	
  
or (modification):  	
4 x 7.92mm machine gun "FN Browning 7.92 mod 1938", 1600 rounds, 1500 rounds per minute, wing-mounted  
2 x 20mm gun "MG FF", 120 rounds, 530 rounds per minute, wing-mounted  
  
or (modification):  	
2 x 7.92mm machine gun "FN Browning 7.92 mod 1938", 1400 rounds, 1500 rounds per minute, wing-mounted  
2 x 20mm gun "MG 151/20", 350 rounds, 700 rounds per minute, wing-mounted  
  
炸弹 (modification)：  
最多2 x 55 kg杀伤炸弹"SC 50"  
249kg 通用炸弹"SC 250"  
  
  
火箭弹：  
两枚位于可抛弃发射管里的WGr.21火箭弹  
26 x R4M火箭弹  
  
长度：8.97 m  
翼展：11.0 m  
机翼面积：16.5 m²  
  
首次投入战斗：Autumn 1942  
  
操作特性：  
- The aircraft has no constant propeller governor. The propeller speed is controlled by manually changing the propeller pitch using a switch on the instrument board (default propeller pitch commands in the sim are [RShift + +/-]).  
- Due to the absence of a constant propeller speed governor, it is necessary to carefully monitor the propeller RPM, especially in a dive - due to the spinning up of the propeller during acceleration, it is possible to exceed the maximum RPM and cause an engine failure.  	
- The aircraft has no cylinder head temperature gauge - only an oil temperature gauge.  
- The oil radiator of the I.A.R. 80-B has no regulation (there is a second adjustable oil radiator on I.A.R. 80-C, I.A.R. 81-C modification).  
- The aircraft is equipped with elevator trimmer.  
- Mixture control is automated, the automatic regulator maintains the set mixture composition and automatically enriches the mixture at low and full throttle. The optimum mixture is set by the centre position of the control lever.  
- The flaps are hydraulic and can be set to any angle up to 75°. In the dive bomber version, the fully released flaps are used as air brake. There is no flap position indicator.  
- The aircraft has differential pneumatic wheel brakes with shared control lever. This means that if the brake lever is held and the rudder pedal the opposite wheel brake is gradually released causing the plane to swing to one side or the other.  
- The aircraft has a hydrostatic fuel gauge which shows total fuel remaining only when manual sucker lever is pushed in. In the sim, hold [RShift+I by default].  
- To drop bombs, you must switch on the bomb releasel system first [N key]. After dropping bombs, the system should be manually deactivated.  
- When the bomb release system is switched on, the flaps are automatically fully released as an air brake and retract automatically either when the bomb release button is pressed or when the system is switched off.  
- The bomb release system can either drop only the central bomb or all three bombs at once.  
- The gunsight is adjustable: both the target distance and target base can be set.  
- In the dive bomber version, the tilt of the gunsight is adjustable [RAlt + F by default].  
- The gunsight has a sliding sun-filter [LAlt + F by default].  
  
## 修改  
  
  
### I.A.R.80-C series 251-290  
  
Armament changed to four 7.92mm MGs and two 20mm MG FF/M guns,  
tail struts, new air filter, second oil radiator,  
sturdier fuselage and flaps.  
增加质量： 24.2 kg  
预期速度损失： 12 km/h  
  
### I.A.R.81-C series 301-450  
  
Armament changed to two 7.92mm MGs and two 20mm MG151/20 guns,  
centerline (249 kg SC 250) and underwing bombs (two 55 kg SC 50),  
tail struts, sturdier flaps.  
增加质量： 426.7 kg  
弹药质量： 387.5 kg  
挂架质量： 20.0 kg  
投弹前预期速度损失： 41 km/h  
投弹后预期速度损失： 19 km/h  