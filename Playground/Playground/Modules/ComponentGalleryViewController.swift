import UIKit
import Core

/// Renders the library's components together, so the README gallery can be captured
/// from a single screen and the states stay visible side by side.
final class ComponentGalleryViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private let filled = InputField()
    private let invalid = InputField()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Focus then blur, then mark invalid. This gives the invalid border. The hint text
        // needs actual typing, see the note in viewDidLoad.
        _ = invalid.becomeFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            _ = self.invalid.resignFirstResponder()
            self.invalid.invalidate()
            // Focusing scrolled the field into view; put it back for the screenshot.
            self.scrollView.setContentOffset(.zero, animated: false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Components"
        view.backgroundColor = .systemBackground

        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        section("InputField")
        let plain = InputField()
        plain.placeholder = "Email address"
        add(plain, height: 64)

        // setText is the way in. InputField.text is a @Published output written as the user
        // types, so assigning to it does not populate the field.
        filled.placeholder = "Email address"
        filled.setText("joey.patino@pm.me")
        add(filled, height: 64)

        // invalidate() repaints the border red, and that much can be staged from outside.
        // The hint underneath cannot: it is gated on editActions containing .edit, which is
        // only inserted by textFieldDidChange, the real-keystroke path. setText does not go
        // through it. Type into this field by hand and the hint appears on blur.
        invalid.placeholder = "Email address"
        invalid.validators = [EmailValidator(validationHint: "Enter a valid email address")]
        invalid.setText("not-an-email")
        add(invalid, height: 78)

        section("PasswordInputField")
        let secure = PasswordInputField()
        secure.placeholder = "Password"
        add(secure, height: 64)

        section("SearchField")
        let search = SearchField()
        search.placeholder = "Search"
        add(search, height: 48)

        section("GradientButton")
        let gradient = GradientButton(
            title: "Continue",
            cornerRadius: 8,
            gradient: Gradient(startColor: .systemPink, endColor: .systemOrange, direction: .leftRight))
        add(gradient, height: 48)

        section("ActivityButton")
        let activity = ActivityButton()
        activity.setTitle("Activity button", for: .normal)
        activity.backgroundColor = .systemIndigo
        activity.layer.cornerRadius = 8
        activity.isActive = true
        add(activity, height: 48)

        // RoundButton constrains width to height, so it needs a row that does not
        // stretch it to the full width of the stack.
        section("RoundButton / SmallButton")
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        let round = RoundButton()
        round.setTitle("+", for: .normal)
        round.backgroundColor = .systemBlue
        round.heightAnchor.constraint(equalToConstant: 48).isActive = true
        row.addArrangedSubview(round)
        row.addArrangedSubview(SmallButton(image: UIImage(systemName: "square.and.arrow.up")))
        row.addArrangedSubview(UIView())
        add(row, height: 48)

        section("RangeSlider")
        add(RangeSlider(), height: 40)

        section("Hr")
        add(Hr(color: .separator), height: 1)
    }

    private func section(_ title: String) {
        let label = UILabel()
        label.text = title.uppercased()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        stack.addArrangedSubview(label)
    }

    private func add(_ view: UIView, height: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        stack.addArrangedSubview(view)
    }
}
