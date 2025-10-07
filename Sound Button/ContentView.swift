//  ContentView.swift
//  Sound Button
//
//  Created by Brian Lee on 9/29/25.
//

import SwiftUI
import AVFAudio
import AVFoundation

// Reusable data object
struct BilingualAnnouncement {
	var zhText: String
	var enText: String
	var zhVoiceID: String = "zh-TW"
	var enVoiceID: String = "en-US"
	var zhRate: Float = 0.5
	var enRate: Float = 0.5
	var zhPitch: Float = 1.1
	var enPitch: Float = 1.2
	var pauseBetween: TimeInterval = 0.2

	func speak(using synthesizer: AVSpeechSynthesizer = SpeechManager.shared.synth) {
		// Chinese
		let zh = AVSpeechUtterance(string: zhText)
		zh.voice = AVSpeechSynthesisVoice(language: zhVoiceID)
		zh.rate = zhRate
		zh.pitchMultiplier = zhPitch
		zh.postUtteranceDelay = pauseBetween

		// English
		let en = AVSpeechUtterance(string: enText)
		en.voice = AVSpeechSynthesisVoice(language: enVoiceID)
		en.rate = enRate
		en.pitchMultiplier = enPitch

		synthesizer.speak(zh)
		synthesizer.speak(en)
	}
}

// Centralized synthesizer (prevents being deallocated mid-speech)
final class SpeechManager {
	static let shared = SpeechManager()
	let synth = AVSpeechSynthesizer()
	private init() {}
}

// Hex → Color
extension Color {
	init(hex: UInt32, alpha: Double = 1.0) {
		self = Color(
			.sRGB,
			red: Double((hex >> 16) & 0xFF) / 255,
			green: Double((hex >> 8) & 0xFF) / 255,
			blue: Double(hex & 0xFF) / 255,
			opacity: alpha
		)
	}
}

// MRT 線顏色
enum MRTLine {
	case green, blue, red, orange, brown, yellow, logoblue, logogreen

	var color: Color {
		switch self {
		case .green:  return Color(hex: 0x008659) // 綠
		case .blue:   return Color(hex: 0x0070bd) // 藍
		case .red:    return Color(hex: 0xe3002c) // 紅
		case .orange: return Color(hex: 0xf8b61c) // 橘
		case .brown:  return Color(hex: 0xc48c31) // 咖啡
		case .yellow: return Color(hex: 0xffdb00) // 黃
		case .logoblue:  return Color(hex: 0x0079a9) // 捷運標誌藍
		case .logogreen: return Color(hex: 0x4bb748) // 捷運標誌綠
		}
	}
}

// 區塊標題
struct SectionHeader: View {
	let title: String
	var body: some View {
		HStack { Text(title).font(.title3.weight(.semibold)); Spacer() }
			.padding(.top, 8).padding(.bottom, 4)
	}
}

// MARK: - 共用：廣播按鈕
struct AnnouncementButton: View {
	let title: String   // 按鈕顯示（短中文）
	let zh: String      // 實際播報的中文
	let en: String      // 實際播報的英文
	var tint: Color? = nil

	var body: some View {
		Button {
			BilingualAnnouncement(zhText: zh, enText: en).speak()
		} label: {
			// 讓文字撐滿卡片寬度並靠左
			Text(title)
				.font(.body.weight(.bold))
				.frame(maxWidth: .infinity, alignment: .center)
		}
		.buttonStyle(.glassProminent)
		.tint(tint ?? .accentColor)
	}
}

// MARK: - 共用：卡片外觀
struct AnnouncementCard<Content: View>: View {
	let title: String
	var cardHeight: CGFloat = 280
	@ViewBuilder var content: () -> Content

	var body: some View {
		VStack(spacing: 2) {
			ScrollView {
				VStack(alignment: .leading, spacing: 12) {
					content()
				}
				.frame(maxWidth: 230, alignment: .leading)
				.padding(12)
			}
		}
		.frame(height: cardHeight)         // 固定卡片高度
		.frame(maxWidth: 300)              // ✅ 限制卡片最大寬度，避免太寬
		.clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous)) // ✅ 先裁成圓角
		.glassEffect(.clear.interactive(), in: .rect(cornerRadius: 22))
		.padding(.horizontal, 16)
	}
}
// MARK: - 車站廣播 Card
struct StationAnnouncementCard: View {
	var body: some View {
		AnnouncementCard(title: "車站廣播") {
			AnnouncementButton(
				title: "手扶梯廣播",
				zh: "請緊握扶手，站穩踏階。",
				en: "Please hold the handrail and step firmly onto the escalator.",
				tint: MRTLine.logogreen.color
			)
			AnnouncementButton(
				title: "列車方向",
				zh: "一月台列車，往松山",
				en: "Platform one, for Songshan.",
				tint: MRTLine.logogreen.color
			)
		}
	}
}

// MARK: - 車廂宣導廣播 Card
struct InCarAnnouncementCard: View {
	var body: some View {
		AnnouncementCard(title: "車廂宣導廣播") {
			AnnouncementButton(
				title: "請勿妨礙動線",
				zh: "您好，請勿坐在車廂地板上、佔用無障礙空間，或倚靠車門或立柱。",
				en: "Please do not sit on the floor or occupy accessible areas. Do not lean against the central pole or handrails.",
				tint: MRTLine.logoblue.color
			)
			AnnouncementButton(
				title: "車門關閉",
				zh: "車門即將關閉。",
				en: "Doors closing.",
				tint: MRTLine.logoblue.color
			)
			AnnouncementButton(
				title: "請遵守先下後上",
				zh: "您好，請分散位置候車，遵守先下後上的乘車秩序。",
				en: "Please spread out along the platform to wait for the train. Let alighting passengers off first.",
				tint: MRTLine.logoblue.color
			)
			AnnouncementButton(
				title: "請小聲交談",
				zh: "您好，使用隨身電子產品請戴耳機，與人交談請醬低音量。",
				en: "Please speak softly and wear headphones when using personal electronics.",
				tint: MRTLine.logoblue.color
			)
			AnnouncementButton(
				title: "請握好扶手",
				zh: "您好，搭乘捷運時，請握緊扶手或拉環。",
				en: "When taking the Metro, please hold on the handrails or hand grips for your safety.",
				tint: MRTLine.logoblue.color
			)
			AnnouncementButton(
				title: "警示音響起勿進出",
				zh: "您好，關門警示音響起時，請勿再進出車廂。",
				en: "Do not rush onto the train once the door closing buzzer has sounded.",
				tint: MRTLine.logoblue.color
			)
			AnnouncementButton(
				title: "請往車廂內部移動",
				zh: "您好，請往車廂內部移動，將後背包提於手上或置於前方，並勿倚靠車門。",
				en: "Please move to the center of the car, and hold your backpack by hand or place it in front of you.",
				tint: MRTLine.logoblue.color
			)
			AnnouncementButton(
				title: "抵達終點站",
				zh: "各位旅客請注意，本列車不再提供載客服務，到站後請儘速下車，謝謝。",
				en: "This service terminates here, please alight at once. Thank you.",
				tint: MRTLine.logoblue.color
			)
			AnnouncementButton(
				title: "禁止吸菸、飲食",
				zh: "您好，捷運系統內請勿吸菸、飲食、矯食口香糖或檳榔。",
				en: "Please do not smoke, eat, drink, or chew gum or betel nut in the Taipei Metro.",
				tint: MRTLine.logoblue.color
			)
			AnnouncementButton(
				title: "接駁轉乘",
				zh: "您好，本列車因接駁轉乘旅客，請稍候。",
				en: "We are stopping briefly to wait for transferring passengers to join us.",
				tint: MRTLine.logoblue.color
			)
		}
	}
}

// MARK: - 到站廣播 Card（依路線顏色）
struct ArrivalAnnouncementCard: View {
	var body: some View {
		AnnouncementCard(title: "到站廣播") {
			// 松山新店線（綠）
			Text("松山新店線").font(.subheadline.bold())
			AnnouncementButton(
				title: "公館",
				zh: "公館",
				en: "Gongguan Station",
				tint: MRTLine.green.color
			)

			Divider().padding(.vertical, 2)

			// 板南線（藍）
			Text("板南線").font(.subheadline.bold())
			AnnouncementButton(
				title: "台北車站",
				zh: "台北車站，轉乘淡水信義線、台鐵、高鐵、桃園機場捷運，請在本站換車。",
				en: "Taipei Main Station, transfer station for the Red Line, Taiwan Railways, Taiwan High Speed Rail, and Taoyuan Airport MRT.",
				tint: MRTLine.blue.color
			)

			Divider().padding(.vertical, 2)

			// 淡水信義線（紅）
			Text("淡水信義線").font(.subheadline.bold())
			AnnouncementButton(
				title: "中正紀念堂",
				zh: "中正紀念堂，南門，轉乘松山新店線，請在本站換車",
				en: "Chiang-Kai Shek Memorial Hall Station, Nanmen, transfer station for the Green Line.",
				tint: MRTLine.red.color
			)

			Divider().padding(.vertical, 2)

			// 中和新蘆線（橘）
			Text("中和新蘆線 (往迴龍列車)").font(.subheadline.bold())
			AnnouncementButton(
				title: "大橋頭",
				zh: "大橋頭，往蘆洲方向的旅客，請在本站換車",
				en: "Dachiaoto Station, transfer station for all stations to Loocho.",
				tint: MRTLine.orange.color
			)

			Divider().padding(.vertical, 2)

			// 文湖線（咖啡）
			Text("文湖線").font(.subheadline.bold())
			AnnouncementButton(
				title: "大安",
				zh: "大安，轉乘淡水信義線，請在本站換車",
				en: "Da-An station, transfer station for the Red Line.",
				tint: MRTLine.brown.color
			)

			Divider().padding(.vertical, 2)

			// 環狀線（黃）
			Text("環狀線").font(.subheadline.bold())
			AnnouncementButton(
				title: "大坪林",
				zh: "終點站，大坪林，轉乘松山新店線，請在本站換車",
				en: "The Terminal Station, Dapinglin station, transfer station for the green line.",
				tint: MRTLine.yellow.color
			)
		}
	}
}
// MARK: - 主視圖
struct ContentView: View {
	@State private var selectedIndex: Int = 0   // ✅ 分頁索引
	private let logoSize: CGFloat = 88

	var body: some View {
		VStack {
			HStack {
				Spacer()
				HStack(alignment: .center, spacing: 16) {
					Image("mrt")
						.resizable()
						.renderingMode(.original)
						.scaledToFit()
						.frame(width: logoSize, height: logoSize)
						.clipShape(RoundedRectangle(cornerRadius: 16))

					VStack(alignment: .center, spacing: 4) {
						Text("台北捷運廣播")
							.font(.largeTitle.bold())
							.multilineTextAlignment(.center)
						Text("台北人的共同記憶")
							.font(.subheadline)
							.foregroundStyle(.secondary)
							.multilineTextAlignment(.center)
					}
				}

				Spacer() // 右側留白，讓整塊置中
			}
			.padding(.top, 8)

			ZStack {
				Image("bg")
					.resizable()
					.scaledToFill()
					.ignoresSafeArea()

				LinearGradient(
					colors: [.black.opacity(0.25), .clear, .black.opacity(0.15)],
					startPoint: .top,
					endPoint: .bottom
				)
				.ignoresSafeArea()

				TabView(selection: $selectedIndex) {

					// 到站廣播
					ZStack {
						Image("bg").resizable().scaledToFill().ignoresSafeArea()
						LinearGradient(colors: [.black.opacity(0.25), .clear, .black.opacity(0.15)],
									   startPoint: .top, endPoint: .bottom)
							.ignoresSafeArea()

						VStack(alignment: .leading, spacing: 10) {
							Text("到站廣播")
								.font(.title3.bold())
								.padding(.horizontal, 12).padding(.vertical, 6)
								.glassEffect(.regular.interactive())
								.clipShape(Capsule())
								.offset(x:310)

							// 卡片
							HStack { Spacer(); ArrivalAnnouncementCard(); Spacer() }
						}
						.padding(.horizontal, 16)
					}
					.tag(0)
					.tabItem {
						Label("到站廣播", systemImage: "tram.fill")
					}

					// 車廂宣導廣播
					ZStack {
						Image("bg").resizable().scaledToFill().ignoresSafeArea()
						LinearGradient(colors: [.black.opacity(0.25), .clear, .black.opacity(0.15)],
									   startPoint: .top, endPoint: .bottom)
							.ignoresSafeArea()

						VStack(alignment: .leading, spacing: 10) {
							Text("車廂宣導廣播")
								.font(.title3.bold())
								.padding(.horizontal, 12).padding(.vertical, 6)
								.glassEffect(.regular.interactive())
								.clipShape(Capsule())
								.offset(x:310)

							HStack { Spacer(); InCarAnnouncementCard(); Spacer() }
						}
						.padding(.horizontal, 16)
					}
					.tag(1)
					.tabItem {
						Label("車廂宣導", systemImage: "figure.wave")
					}

					// 車站廣播
					ZStack {
						Image("bg").resizable().scaledToFill().ignoresSafeArea()
						LinearGradient(colors: [.black.opacity(0.25), .clear, .black.opacity(0.15)],
									   startPoint: .top, endPoint: .bottom)
							.ignoresSafeArea()

						VStack(alignment: .leading, spacing: 10) {
							Text("車站廣播")
								.font(.title3.bold())
								.padding(.horizontal, 12).padding(.vertical, 6)
								.glassEffect(.regular.interactive())
								.clipShape(Capsule())
								.offset(x:310)

							HStack { Spacer(); StationAnnouncementCard(); Spacer() }
						}
						.padding(.horizontal, 16)
					}
					.tag(2)
					.tabItem {
						Label("車站廣播", systemImage: "building.columns.fill")
					}
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				
				Button("停止播放") {
						SpeechManager.shared.synth.stopSpeaking(at: .word)
					}
					.font(.headline).bold()
					.buttonStyle(.glassProminent)
					.offset(y:180)
			}
		}
	}
}

#Preview{
	ContentView()
}


