import SwiftUI
import Charts
import UIKit

public struct LivePingHUDView: View {
    @StateObject private var viewModel = PingHUDViewModel()
    
    private let neonGreen = Color(red: 0, green: 230/255, blue: 118/255)
    private let neonCyan = Color(red: 0, green: 229/255, blue: 255/255)
    private let neonYellow = Color(red: 255/255, green: 214/255, blue: 0)
    private let neonRed = Color(red: 255/255, green: 82/255, blue: 82/255)
    
    public var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 10/255, green: 14/255, blue: 26/255),
                        Color(red: 5/255, green: 8/255, blue: 16/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("LIVE TELEMETRY HUD")
                                    .font(.system(size: 13, weight: .black, design: .monospaced))
                                    .foregroundColor(neonCyan)
                                    .tracking(2)
                                
                                Text("Real-Time Latency")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Pulse indicator
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(neonGreen)
                                    .frame(width: 8, height: 8)
                                    .neonGlow(color: neonGreen, radius: 4)
                                
                                Text("MONITORING")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(neonGreen)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(20)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Target Selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(viewModel.availableTargets) { target in
                                    let isSelected = viewModel.pingService.selectedTarget.id == target.id
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        viewModel.selectTarget(target)
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: target.iconName)
                                                .font(.system(size: 13))
                                            Text(target.name)
                                                .font(.system(size: 12, weight: .semibold))
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .foregroundColor(isSelected ? .black : .white)
                                        .background(
                                            isSelected ?
                                                LinearGradient(colors: [neonCyan, neonGreen], startPoint: .leading, endPoint: .trailing) :
                                                LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)], startPoint: .top, endPoint: .bottom)
                                        )
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isSelected ? Color.clear : Color.white.opacity(0.12), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Real-time Swift Charts Graph
                        GlassCard {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("LATENCY WAVEFORM (MS)")
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .foregroundColor(.gray)
                                        
                                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                                            Text(String(format: "%.1f", viewModel.pingService.stats.currentPing))
                                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                                .foregroundColor(neonGreen)
                                            
                                            Text("ms")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("STABILITY INDEX")
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .foregroundColor(.gray)
                                        
                                        Text("\(viewModel.pingService.stats.stabilityScore)%")
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                            .foregroundColor(viewModel.pingService.stats.stabilityScore > 85 ? neonGreen : neonYellow)
                                    }
                                }
                                
                                // Swift Charts Chart
                                Chart {
                                    ForEach(Array(viewModel.pingService.latencyHistory.enumerated()), id: \.element.id) { index, sample in
                                        LineMark(
                                            x: .value("Sample", index),
                                            y: .value("Latency", sample.latencyMs)
                                        )
                                        .interpolationMethod(.monotone)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [neonCyan, neonGreen],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                                        
                                        AreaMark(
                                            x: .value("Sample", index),
                                            y: .value("Latency", sample.latencyMs)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [neonCyan.opacity(0.3), neonGreen.opacity(0.02)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading) { value in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                                            .foregroundStyle(Color.white.opacity(0.1))
                                        AxisValueLabel {
                                            if let val = value.as(Double.self) {
                                                Text("\(Int(val))")
                                                    .font(.system(size: 9))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                                .chartXAxis(.hidden)
                                .frame(height: 170)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Detailed Telemetry 4-Pillars Grid
                        HStack(spacing: 12) {
                            GaugeRingView(
                                value: viewModel.pingService.stats.jitter,
                                maxValue: 20,
                                title: "JITTER",
                                unit: "ms",
                                primaryColor: neonCyan,
                                size: 85
                            )
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(14)
                            
                            GaugeRingView(
                                value: viewModel.pingService.stats.packetLossPercent,
                                maxValue: 10,
                                title: "PACKET LOSS",
                                unit: "%",
                                primaryColor: viewModel.pingService.stats.packetLossPercent > 1 ? neonRed : neonGreen,
                                size: 85
                            )
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(14)
                            
                            GaugeRingView(
                                value: viewModel.pingService.stats.avgPing,
                                maxValue: 100,
                                title: "AVG PING",
                                unit: "ms",
                                primaryColor: neonYellow,
                                size: 85
                            )
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal)
                        
                        // Min / Max Summary Row
                        GlassCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("MIN LATENCY")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(.gray)
                                    Text(viewModel.pingService.stats.minPing < 900 ? String(format: "%.1f ms", viewModel.pingService.stats.minPing) : "--")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(neonGreen)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .center, spacing: 4) {
                                    Text("MAX PEAK")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(.gray)
                                    Text(String(format: "%.1f ms", viewModel.pingService.stats.maxPing))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(neonRed)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("PACKETS")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(.gray)
                                    Text("\(viewModel.pingService.stats.totalPacketsReceived)/\(viewModel.pingService.stats.totalPacketsSent)")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}
