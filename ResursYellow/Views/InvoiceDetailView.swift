//
//  InvoiceDetailView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-11-09.
//

import SwiftUI

struct InvoiceData: Hashable {
    let merchant: String
    let amount: String
    let dueDate: String
    let invoiceNumber: String
    let issueDate: String
    let status: String
    let color: Color
}

struct InstallmentPlan: Identifiable, Equatable {
    let id = UUID()
    let months: Int
    let interestRate: Double // e.g., 0.0 for 0%
    let fee: Double // fixed fee in SEK
    let monthlyCost: Double
    let totalCost: Double
    var title: String { "\(months) months" }
    var subtitle: String {
        let interest = Int(interestRate * 100)
        return "Interest \(interest)% · Fee \(Int(fee)) kr"
    }
}

struct InvoiceDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var scrollObserver = ScrollOffsetObserver()
    @State private var showPaymentSheet = false
    @State private var isPaying = false
    @State private var isPaid = false
    @State private var paymentSheetHeight: CGFloat = 0
    @State private var paidAmount: Double? = nil
    @State private var planSheetHeight: CGFloat = 0

    let invoice: InvoiceData

    private var isInvoicePaid: Bool {
        invoice.status.contains("Paid on")
    }

    private var isInvoiceScheduled: Bool {
        invoice.status.contains("Scheduled")
    }

    private var shouldShowPayButton: Bool {
        !isInvoicePaid && !isPaid && !isInvoiceScheduled
    }

    var body: some View {
        let scrollProgress = min(scrollObserver.offset / 100, 1.0)

        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Scrollable Content
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Tracking element
                            GeometryReader { geo in
                                Color.clear
                                    .onChange(of: geo.frame(in: .named("scroll")).minY) { oldValue, newValue in
                                        scrollObserver.offset = max(0, -newValue)
                                    }
                            }
                            .frame(height: 0)
                            .id("scrollTop")

                            // Account for header height
                            Color.clear.frame(height: 80)

                            VStack(spacing: 16) {
                                // Invoice Details Card
                                InvoiceDetailsCard(invoice: invoice, isPaid: isPaid || isInvoicePaid, paidAmount: paidAmount)
                                .padding(.horizontal)
                                .padding(.top, 36)
                                .frame(width: geometry.size.width)

                                // Payment Information Card
                                if !isInvoicePaid {
                                    PaymentInformationCard(
                                        isScheduled: isInvoiceScheduled,
                                        merchant: invoice.merchant,
                                        amount: invoice.amount,
                                        ocr: invoice.invoiceNumber,
                                        bankgiro: "123-4567"
                                    )
                                        .padding(.horizontal)
                                        .frame(width: geometry.size.width)
                                }

                                // Payment Options
                                if shouldShowPayButton {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Actions")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                            .padding(.top, 8)
                                        PaymentOptionsCard(
                                            onPayInFull: {
                                                showPaymentSheet = true
                                            },
                                            onSnooze: {
                                                // Handle snooze action
                                                // Could show a date picker sheet or similar
                                            }
                                        )
                                    }
                                    .padding(.horizontal)
                                    .frame(width: geometry.size.width)
                                }
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                            .frame(width: geometry.size.width)
                        }
                        .frame(width: geometry.size.width)
                    }
                    .frame(width: geometry.size.width)
                    .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            proxy.scrollTo("scrollTop", anchor: .top)
                        }
                    }
                }
            }
            .coordinateSpace(name: "scroll")

            // Sticky Header
            VStack(spacing: 0) {
                ZStack {
                    // Back + Pay
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        Spacer()
                        if shouldShowPayButton && scrollProgress > 0.5 {
                            Button(action: { showPaymentSheet = true }) {
                                Image(systemName: "arrow.up")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Minimized title
                    if scrollProgress > 0.5 {
                        Text(invoice.merchant)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, scrollProgress > 0.5 ? 8 : 12)

                // Title and subtitle
                if scrollProgress <= 0.5 {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Invoice Details")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .opacity(1.0 - scrollProgress * 2)

                            Text(invoice.merchant)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        if shouldShowPayButton {
                            Button(action: { showPaymentSheet = true }) {
                                Image(systemName: "arrow.up")
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
            .background(Color(uiColor: .systemBackground).opacity(0.95))
            .background(.ultraThinMaterial)
            .animation(.easeInOut(duration: 0.2), value: scrollProgress)
            .frame(width: geometry.size.width)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPaymentSheet) {
            PaymentSheet(
                invoice: invoice,
                paidAmount: $paidAmount,
                onPaymentCompleted: {
                    withAnimation {
                        isPaid = true
                    }
                },
                onSizeChange: { height in paymentSheetHeight = height }
            )
            .presentationDetents([.height(max(200, min(paymentSheetHeight, UIScreen.main.bounds.height - 60)))])
            .presentationDragIndicator(.visible)
        }
    }
}

struct InvoiceDetailsCard: View {
    let invoice: InvoiceData
    let isPaid: Bool
    let paidAmount: Double?

    private func formatSEK(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        f.maximumFractionDigits = 0
        return (f.string(from: NSNumber(value: value)) ?? "\(Int(value))") + " kr"
    }

    private var paidLabel: String {
        if let amount = paidAmount {
            return "\(formatSEK(amount)) paid"
        }
        return "Paid"
    }

    var body: some View {
        VStack(spacing: 16) {
            // Status Badge
            if isPaid {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                    Text("Payment Scheduled")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.green.opacity(0.1))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Amount
            VStack(spacing: 8) {
                Text(invoice.amount)
                    .font(.system(size: 48, weight: .bold))

                HStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .font(.caption)
                        .foregroundColor(invoice.color)
                    Text(isPaid ? paidLabel : invoice.status)
                        .font(.subheadline)
                        .foregroundColor(isPaid ? .green : invoice.color)
                }
            }

            Divider()

            // Details
            VStack(spacing: 12) {
                DetailRow(label: "Merchant", value: invoice.merchant)
                DetailRow(label: "Invoice Number", value: invoice.invoiceNumber)
                DetailRow(label: "Issue Date", value: invoice.issueDate)
                DetailRow(label: "Due Date", value: invoice.dueDate)
                DetailRow(label: "Status", value: isPaid ? paidLabel : invoice.status)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct PaymentInformationCard: View {
    let isScheduled: Bool
    let merchant: String
    let amount: String
    let ocr: String
    let bankgiro: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isScheduled ? "calendar.circle.fill" : "info.circle.fill")
                    .font(.title3)
                    .foregroundColor(isScheduled ? .cyan : .blue)

                Text(isScheduled ? "Scheduled Payment" : "Payment Information")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            if isScheduled {
                VStack(spacing: 8) {
                    HStack(alignment: .top) {
                        Text("Status")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Auto-pay scheduled")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    Divider()

                    HStack {
                        Text("Payment Method")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "creditcard.fill")
                                .font(.caption)
                                .foregroundColor(.cyan)
                            Text("Nordea *894")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Text("Amount")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(amount)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Button(action: {
                            UIPasteboard.general.string = amount
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Divider()

                    HStack {
                        Text("OCR")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(ocr)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Button(action: {
                            UIPasteboard.general.string = ocr
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Divider()

                    HStack {
                        Text("Bankgiro")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(bankgiro)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Button(action: {
                            UIPasteboard.general.string = bankgiro
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Divider()

                    HStack {
                        Text("Invoice PDF")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        HStack(spacing: 6) {
                            Text("Open")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Image(systemName: "arrow.up.right.circle")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background((isScheduled ? Color.cyan : Color.blue).opacity(0.1))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct InvoiceItemsCard: View {
    let merchant: String

    private var items: [(name: String, quantity: String, price: String, total: String)] {
        switch merchant {
        case "Netonnet":
            return [
                ("TV Wall Mount", "1", "399 SEK", "1 568 SEK"),
                ("HDMI Cable 3m", "2", "298 SEK", "1 568 SEK"),
                ("Power Strip", "1", "249 SEK", "1 568 SEK"),
                ("Cable Management", "1", "179 SEK", "1 568 SEK"),
                ("Universal Remote", "1", "443 SEK", "1 568 SEK")
            ]
        case "Bauhaus":
            return [
                ("Paint Roller Set", "2", "298 kr", "4 356 kr"),
                ("Interior Paint 10L", "3", "800 kr", "4 356 kr"),
                ("Painter's Tape", "4", "200 kr", "4 356 kr"),
                ("Drop Cloth", "2", "200 kr", "4 356 kr"),
                ("Paint Tray Kit", "1", "160 kr", "4 356 kr")
            ]
        case "Gekås":
            return [
                ("Winter Jacket", "1", "495 SEK", "895 SEK"),
                ("Wool Socks 3-pack", "1", "149 SEK", "895 SEK"),
                ("Thermal Underwear", "1", "251 SEK", "895 SEK")
            ]
        case "Elgiganten":
            return [
                ("Bluetooth Speaker", "1", "549 SEK", "900 SEK"),
                ("Phone Case", "1", "199 SEK", "900 SEK"),
                ("USB-C Cable 2m", "1", "152 SEK", "900 SEK")
            ]
        case "Clas Ohlson":
            return [
                ("LED Desk Lamp", "1", "349 SEK", "785 SEK"),
                ("Batteries AA 20-pack", "1", "179 SEK", "785 SEK"),
                ("Extension Cord 3m", "1", "257 SEK", "785 SEK")
            ]
        case "Stadium":
            return [
                ("Running Shoes", "1", "1 299 SEK", "2 340 SEK"),
                ("Sports Bag", "1", "549 SEK", "2 340 SEK"),
                ("Water Bottle", "2", "246 SEK", "2 340 SEK"),
                ("Gym Towel", "1", "246 SEK", "2 340 SEK")
            ]
        case "ICA":
            return [
                ("Groceries", "1", "452 SEK", "452 SEK")
            ]
        case "Åhléns":
            return [
                ("Face Cream", "1", "189 SEK", "300 SEK"),
                ("Hand Soap", "2", "111 SEK", "300 SEK")
            ]
        default:
            return [("Item", "1", "0 SEK", "0 SEK")]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Items")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                ForEach(items.indices, id: \.self) { index in
                    InvoiceItemRow(
                        name: items[index].name,
                        quantity: items[index].quantity,
                        price: items[index].price
                    )
                }

                Divider()

                HStack {
                    Text("Total")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(items.first?.total ?? "0 SEK")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct InvoiceItemRow: View {
    let name: String
    let quantity: String
    let price: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("Qty: \(quantity)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(price)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

struct PaymentOptionsCard: View {
    let onPayInFull: () -> Void
    let onSnooze: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            PaymentOptionRow(
                icon: "arrow.up",
                title: "Pay Invoice",
                description: "Pay this month's balance",
                color: .blue,
                isDefaultOption: false,
                action: onPayInFull
            )

            PaymentOptionRow(
                icon: "clock.badge.checkmark.fill",
                title: "Snooze",
                description: "Postpone payment to a later date",
                color: .green,
                action: onSnooze
            )
        }
    }
}

struct PaymentOptionRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    var isDefaultOption: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()

            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.22))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(16)
            .background(isPressed ? color.opacity(0.34) : color.opacity(0.24))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        isPressed = false
                    }
                }
        )
    }
}

struct PaymentSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var paymentDate = Date()
    @State private var isProcessing = false

    @State private var showPlanOptions: Bool = false
    @State private var selectedPlan: InstallmentPlan? = nil
    @State private var planSheetHeight: CGFloat = 0
    @State private var displayAmount: Double = 0
    @State private var amountTimer: Timer? = nil
    @State private var pendingTargetAmount: Double? = nil
    @State private var insuranceEnabled: Bool = false
    @State private var showCreditRisk: Bool = false

    let invoice: InvoiceData
    @Binding var paidAmount: Double?
    let onPaymentCompleted: () -> Void
    let onSizeChange: (CGFloat) -> Void

    private var invoiceBaseAmount: Double {
        let amountString = invoice.amount
            .replacingOccurrences(of: "kr", with: "")
            .replacingOccurrences(of: "SEK", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Double(amountString) ?? 0
    }

    private var availablePlans: [InstallmentPlan] {
        let base = invoiceBaseAmount
        func plan(_ months: Int, interest: Double, fee: Double) -> InstallmentPlan {
            let total = base * (1 + interest) + fee
            let monthly = months > 0 ? total / Double(months) : total
            return InstallmentPlan(months: months, interestRate: interest, fee: fee, monthlyCost: monthly, totalCost: total)
        }
        return [
            InstallmentPlan(months: 0, interestRate: 0, fee: 0, monthlyCost: base, totalCost: base),
            plan(3, interest: 0.00, fee: 0),
            plan(6, interest: 0.00, fee: 0),
            plan(12, interest: 0.06, fee: 199),
            plan(24, interest: 0.09, fee: 299)
        ]
    }

    private func formatSEK(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        f.maximumFractionDigits = 0
        return (f.string(from: NSNumber(value: value)) ?? "\(Int(value))") + " kr"
    }

    private var targetAmount: Double {
        if let selected = selectedPlan, selected.months != 0 {
            return adjustedMonthly(for: selected)
        }
        return invoiceBaseAmount
    }

    private var isPartPaymentSelected: Bool {
        (selectedPlan?.months ?? 0) != 0
    }

    private var isOverdueInvoice: Bool {
        invoice.status.lowercased().contains("overdue")
    }

    private var dueDateValue: Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.date(from: invoice.dueDate)
    }

    private func datesEqual(_ lhs: Date?, _ rhs: Date?) -> Bool {
        guard let lhs, let rhs else { return false }
        return Calendar.current.isDate(lhs, inSameDayAs: rhs)
    }

    private func ensureSelectionDefault() {
        if selectedPlan == nil {
            selectedPlan = availablePlans.first
        }
    }

    private func finalizePayment() {
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            paidAmount = targetAmount
            onPaymentCompleted()
            dismiss()
        }
    }

    private func adjustedMonthly(for plan: InstallmentPlan) -> Double {
        guard plan.months > 0 else { return plan.monthlyCost }
        let surchargeTotal = plan.totalCost * 0.004 // 0.4% of total
        let surchargePerMonth = surchargeTotal / Double(plan.months)
        return plan.monthlyCost + (insuranceEnabled ? surchargePerMonth : 0)
    }

    private func adjustedTotal(for plan: InstallmentPlan) -> Double {
        guard plan.months > 0 else { return plan.totalCost }
        let surchargeTotal = plan.totalCost * 0.004
        return insuranceEnabled ? (plan.totalCost + surchargeTotal) : plan.totalCost
    }

    private func animateAmountChange(to newValue: Double) {
        amountTimer?.invalidate()

        let startValue = displayAmount
        guard startValue != newValue else { return }

        let duration: Double = 1.0
        let fps: Double = 60.0
        let steps = max(1, Int(duration * fps))
        var currentStep = 0
        let delta = newValue - startValue

        let timer = Timer.scheduledTimer(withTimeInterval: 1 / fps, repeats: true) { timer in
            currentStep += 1
            let progress = min(Double(currentStep) / Double(steps), 1)
            let eased = 1 - pow(1 - progress, 3) // ease-out cubic for a soft finish
            displayAmount = startValue + delta * eased

            if currentStep >= steps {
                timer.invalidate()
                amountTimer = nil
                displayAmount = newValue
            }
        }

        amountTimer = timer
    }

    var body: some View {
        VStack(spacing: 12) {
            // Payment Amount (title removed per design)
            VStack(spacing: 8) {
                Text(formatSEK(displayAmount))
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.blue)
                    .accessibilityLabel("Amount \(formatSEK(displayAmount))")
                Button(action: {
                    ensureSelectionDefault()
                    showPlanOptions = true
                }) {
                    Text("Change Amount")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 36)
            .onAppear {
                ensureSelectionDefault()
                paymentDate = isOverdueInvoice ? Date() : (dueDateValue ?? Date())
                displayAmount = targetAmount
            }
            .onChange(of: targetAmount) { _, newValue in
                if showPlanOptions {
                    pendingTargetAmount = newValue
                } else {
                    animateAmountChange(to: newValue)
                }
            }
            .onChange(of: showPlanOptions) { _, isPresented in
                if !isPresented {
                    let next = pendingTargetAmount ?? targetAmount
                    pendingTargetAmount = nil
                    animateAmountChange(to: next)
                }
            }
            .onDisappear {
                amountTimer?.invalidate()
                amountTimer = nil
            }

            VStack(alignment: .leading, spacing: 12) {
                // Account Card
                HStack(alignment: .center) {
                    Image(systemName: "creditcard.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .frame(width: 36, height: 36)
                        .background(Color.blue.opacity(0.2))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nordea *894")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Checking account")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Change")
                            .font(.caption.weight(.semibold))
                        Image(systemName: "chevron.forward")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(.blue)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 8)

                // Payment Plan Card
                Button(action: { showPlanOptions = true }) {
                    HStack(alignment: .top) {
                        Image(systemName: "list.bullet.rectangle.fill")
                            .font(.title3)
                            .foregroundColor(.purple)
                            .frame(width: 36, height: 36)
                            .background(Color.purple.opacity(0.2))
                            .clipShape(Circle())

                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                let isFull = (selectedPlan == nil || selectedPlan?.months == 0)
                                Text(isFull ? "Full payment" : (selectedPlan?.title ?? "Full payment"))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                if isFull {
                                    Text("One payment. Total \(invoice.amount)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else if let plan = selectedPlan {
                                    Text("\(Int(plan.monthlyCost)) kr / month · Total \(Int(plan.totalCost)) kr")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if insuranceEnabled && plan.months >= 12 {
                                        Text("Payment insurance included")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            Spacer()
                        HStack(spacing: 4) {
                            Text("Part Pay")
                                .font(.caption.weight(.semibold))
                            Image(systemName: "chevron.forward")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundColor(.blue)
                        }
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                // Payment Date
                if isOverdueInvoice {
                    HStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 36, height: 36)
                            .background(Color.blue.opacity(0.15))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pay now")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                            Text("Overdue invoice")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 36, height: 36)
                            .background(Color.blue.opacity(0.15))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            let defaultDue = dueDateValue
                            let isCustom = !datesEqual(paymentDate, defaultDue)
                            let isAfterDue = {
                                guard let due = defaultDue else { return false }
                                return paymentDate > due && !Calendar.current.isDate(paymentDate, inSameDayAs: due)
                            }()
                            Text(isCustom ? "Custom date" : "On due date")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                            Text(isCustom ? (isAfterDue ? "After due" : "Your choice") : "Pay just in time")
                                .font(.caption)
                                .foregroundColor(isAfterDue ? .orange : .secondary)
                        }

                        Spacer()

                        DatePicker(
                            "Payment Date",
                            selection: $paymentDate,
                            in: Date()...,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .accessibilityLabel("Payment date")
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Text("Scheduling a payment is a request to your bank to make a transfer. The request can be declined or fail for several reasons, and you must ensure there are sufficient funds in the selected account at the time of the requested transfer.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 4)
            }
            .padding(.horizontal)

            // Confirm Button
            Button(action: {
                if (selectedPlan?.months ?? 0) != 0 {
                    showCreditRisk = true
                } else {
                    finalizePayment()
                }
            }) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                    }
                    Text(isProcessing ? "Processing..." : "Confirm Payment")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isProcessing ? Color.gray : Color.blue)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 6)
            }
            .disabled(isProcessing)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(UIColor.systemBackground))
        .fixedSize(horizontal: false, vertical: true)
        .fullScreenCover(isPresented: $showCreditRisk) {
            CreditRiskOverlay(
                onAcknowledge: {
                    finalizePayment()
                    showCreditRisk = false
                },
                onCancel: {
                    showCreditRisk = false
                }
            )
        }
        .overlay(alignment: .topTrailing) {
            Button(action: { if !isProcessing { dismiss() } }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
            }
            .padding(.trailing, 16)
            .padding(.top, 16)
            .accessibilityLabel("Close")
            .buttonStyle(.plain)
            .disabled(isProcessing)
            .opacity(isProcessing ? 0.4 : 1)
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { onSizeChange(geo.size.height) }
                    .onChange(of: geo.size.height) { _, newValue in
                        onSizeChange(newValue)
                    }
            }
        )
        .sheet(isPresented: $showPlanOptions) {
            PlanOptionsListSheet(
                plans: availablePlans,
                selectedPlan: selectedPlan,
                insuranceEnabled: $insuranceEnabled,
                onSelect: { plan in
                    selectedPlan = plan
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

struct PlanOptionsSheet: View {
    let plans: [InstallmentPlan]
    let selectedPlan: InstallmentPlan?
    @Binding var insuranceEnabled: Bool
    let onSelect: (InstallmentPlan) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var sliderIndex: Double = 0

    private func fmt(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }

    private var sliderRange: ClosedRange<Double> {
        0...Double(max(plans.count - 1, 0))
    }

    private var currentIndex: Int {
        guard !plans.isEmpty else { return 0 }
        return min(max(Int(round(sliderIndex)), 0), plans.count - 1)
    }

    private var currentPlan: InstallmentPlan? {
        guard !plans.isEmpty else { return nil }
        return plans[currentIndex]
    }

    private func initialIndex() -> Double {
        if let selected = selectedPlan {
            if let match = plans.firstIndex(where: {
                $0.months == selected.months &&
                abs($0.interestRate - selected.interestRate) < 0.0001 &&
                abs($0.fee - selected.fee) < 0.01
            }) {
                return Double(match)
            }
        }
        // Default to 3 months if available, else first
        if let threeIndex = plans.firstIndex(where: { $0.months == 3 }) {
            return Double(threeIndex)
        }
        return 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Grabber + close
            ZStack {
                Capsule()
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 0)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.primary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
            }

            ZStack {
                // Centered title
                Text("Pay Over Time")
                    .font(.headline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
            .overlay(alignment: .topLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.bottom, 12)

            if plans.isEmpty {
                Text("No payment plans available right now.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                if let plan = currentPlan {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(plan.months == 0 ? "Full payment" : plan.title)
                            .font(.headline.weight(.semibold))

                        let surchargeTotal = plan.totalCost * 0.004
                        let surchargePerMonth = plan.months > 0 ? surchargeTotal / Double(plan.months) : 0
                        let monthly = plan.months > 0 ? plan.monthlyCost + (insuranceEnabled ? surchargePerMonth : 0) : plan.monthlyCost
                        let total = plan.months > 0 ? plan.totalCost + (insuranceEnabled ? surchargeTotal : 0) : plan.totalCost

                        if plan.months == 0 {
                            Text("One payment · Total \(fmt(plan.totalCost)) kr")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("No fees or interest")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if selectedPlan?.months == 0 {
                                Divider().padding(.vertical, 4)
                                Toggle(isOn: Binding(get: {
                                    false
                                }, set: { _ in })) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Clear all debt")
                                            .font(.subheadline.weight(.semibold))
                                        Text("Also pay debt not yet invoiced")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                .disabled(true)
                            }
                        } else {
                            Text("\(fmt(monthly)) kr / month · Total \(fmt(total)) kr")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text(plan.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                            Text("Interest \(Int(plan.interestRate * 100))% · Fee \(Int(plan.fee)) kr")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if plan.months >= 12 {
                            Divider().padding(.vertical, 4)
                            Toggle(isOn: $insuranceEnabled) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Add Payment Insurance")
                                        .font(.subheadline.weight(.semibold))
                                    Text("Adds 0.4% of total to monthly amount")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .animation(.spring(response: 0.35, dampingFraction: 0.82), value: currentPlan?.id)
                    .animation(.spring(response: 0.35, dampingFraction: 0.82), value: insuranceEnabled)
                }

                VStack(spacing: 10) {
                    Slider(
                        value: $sliderIndex,
                        in: sliderRange,
                        step: 1
                    ) { }
                    .padding(.horizontal, 4)
                    .onChange(of: sliderIndex) { _, _ in
                        if let plan = currentPlan {
                            onSelect(plan)
                        }
                    }

                    HStack {
                        Text(plans.first?.months == 0 ? "Full" : (plans.first?.title ?? ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(plans.last?.title ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Credit warning: Borrowing costs money. Be sure you can repay, as missed payments can lead to fees and debt. Consider your budget carefully before choosing a payment plan.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                if let plan = currentPlan {
                    Button(action: {
                        onSelect(plan)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("Confirm Selection")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            sliderIndex = initialIndex()
            if let plan = currentPlan {
                onSelect(plan)
            }
        }
        .onChange(of: insuranceEnabled) { _, _ in
            if let plan = currentPlan {
                onSelect(plan)
            }
        }
    }

}

struct PlanOptionsListSheet: View {
    let plans: [InstallmentPlan]
    let selectedPlan: InstallmentPlan?
    @Binding var insuranceEnabled: Bool
    let onSelect: (InstallmentPlan) -> Void

    @State private var localSelection: InstallmentPlan? = nil

    @Environment(\.dismiss) private var dismiss

    private func fmt(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        f.maximumFractionDigits = 0
        return (f.string(from: NSNumber(value: value)) ?? "\(Int(value))")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 32, height: 32)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                }

                Spacer(minLength: 0)

                Text("Select Payment Option")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer(minLength: 0)

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.primary)
                        .frame(width: 32, height: 32)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            .padding(.bottom, 12)

            ScrollView {
                VStack(spacing: 12) {
                    let activeSelection = localSelection ?? selectedPlan ?? plans.first
                    let currentSelectionMonths = activeSelection?.months
                    ForEach(plans) { plan in
                        let isSelected = currentSelectionMonths == plan.months
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                localSelection = plan
                                onSelect(plan)
                            }
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        if plan.months == 0 {
                                            Text("Full payment")
                                                .font(.subheadline).fontWeight(.semibold)
                                            Text("One payment · Total \(fmt(plan.totalCost)) kr")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            if isSelected {
                                                Divider().padding(.vertical, 4)
                                                Toggle(isOn: Binding(get: {
                                                    false
                                                }, set: { _ in })) {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text("Clear all debt")
                                                            .font(.caption.weight(.semibold))
                                                        Text("Also pay debt not yet invoiced")
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                                .disabled(true)
                                            }
                                        } else {
                                            Text("\(fmt(plan.monthlyCost)) kr / month")
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(.primary)
                                            Text("\(plan.title) · Total \(fmt(plan.totalCost)) kr")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text("Interest \(Int(plan.interestRate * 100))% · Fee \(Int(plan.fee)) kr")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }

                                if plan.months >= 12 && isSelected {
                                    Divider()
                                    Toggle(isOn: $insuranceEnabled) {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Add Payment Insurance")
                                                    .font(.caption.weight(.semibold))
                                                Text("Adds 0.4% of total to monthly amount")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                    }
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: isSelected ? 1.5 : 0)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .animation(.easeInOut(duration: 0.25), value: isSelected)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            .animation(.easeInOut(duration: 0.25), value: localSelection?.id)
            .animation(.easeInOut(duration: 0.25), value: insuranceEnabled)

            Button(action: {
                let plan = localSelection ?? selectedPlan ?? plans.first
                if let plan { onSelect(plan) }
                dismiss()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.blue)
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text("Confirm Selection")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, minHeight: 54, maxHeight: 54)
                .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .disabled(false)
            .opacity(1)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .task {
            if localSelection == nil {
                let initial = selectedPlan ?? plans.first
                if let initial {
                    localSelection = initial
                    onSelect(initial)
                }
            }
        }
    }
}

struct CreditRiskOverlay: View {
    let onAcknowledge: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Grabber + close
                    ZStack {
                        Capsule()
                            .fill(Color.secondary.opacity(0.4))
                            .frame(width: 40, height: 5)
                            .padding(.top, 0)
                            .frame(maxWidth: .infinity, alignment: .center)

                        HStack {
                            Spacer()
                            Button(action: onCancel) {
                                Image(systemName: "xmark")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.primary)
                                    .frame(width: 36, height: 36)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                            }
                            .padding(.trailing, 16)
                            .padding(.top, 16)
                        }
                    }

                    Text("Credit is a risk")
                        .font(.largeTitle.weight(.bold))
                        .padding(.top, 8)

                    Text("""
Credit involves borrowing money that must be repaid with interest and fees. Taking on credit can affect your financial stability, and missed or late payments may lead to additional charges, collection actions, and negative impacts on your creditworthiness. Changes in income, unexpected expenses, or higher interest costs can increase the risk of not meeting payment obligations. Always ensure you understand the total cost, repayment schedule, and consequences of non-payment before proceeding.
""")
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    Text("""
By proceeding, you acknowledge that:
• You are responsible for repaying the credit according to the terms.
• Charges, interest, and fees may apply if payments are late or missed.
• Your bank or lender may decline or reverse the transaction if conditions are not met.
• Failing to repay may impact your ability to obtain credit in the future.
""")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)

                    Button(action: onAcknowledge) {
                        Text("I understand")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .background(Color(UIColor.systemBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                }
            }
        }
    }
}

#Preview {
    InvoiceDetailView(
        invoice: InvoiceData(
            merchant: "Netonnet",
            amount: "1 568 SEK",
            dueDate: "Nov 12, 2025",
            invoiceNumber: "INV-2025-11-001",
            issueDate: "Nov 5, 2025",
            status: "Due in 3 days",
            color: .yellow
        )
    )
    .preferredColorScheme(.dark)
}

