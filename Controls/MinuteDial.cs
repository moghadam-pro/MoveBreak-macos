using System.Globalization;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Automation.Peers;
using System.Windows.Automation.Provider;
using System.Windows.Input;
using System.Windows.Media;
using Brush = System.Windows.Media.Brush;
using Brushes = System.Windows.Media.Brushes;
using FontFamily = System.Windows.Media.FontFamily;
using KeyEventArgs = System.Windows.Input.KeyEventArgs;
using MouseEventArgs = System.Windows.Input.MouseEventArgs;
using Pen = System.Windows.Media.Pen;
using Point = System.Windows.Point;
using Size = System.Windows.Size;

namespace MoveBreak.Controls;

public sealed class MinuteDial : FrameworkElement
{
    public static readonly DependencyProperty ValueProperty = DependencyProperty.Register(
        nameof(Value),
        typeof(int),
        typeof(MinuteDial),
        new FrameworkPropertyMetadata(
            45,
            FrameworkPropertyMetadataOptions.AffectsRender |
            FrameworkPropertyMetadataOptions.BindsTwoWayByDefault,
            null,
            (_, value) => Math.Clamp((int)value, 1, 60)));

    public static readonly DependencyProperty FaceBrushProperty = BrushProperty(nameof(FaceBrush), Brushes.White);
    public static readonly DependencyProperty DialBorderBrushProperty = BrushProperty(nameof(DialBorderBrush), Brushes.LightGray);
    public static readonly DependencyProperty TickBrushProperty = BrushProperty(nameof(TickBrush), Brushes.Gray);
    public static readonly DependencyProperty HandBrushProperty = BrushProperty(nameof(HandBrush), Brushes.Teal);
    public static readonly DependencyProperty TextBrushProperty = BrushProperty(nameof(TextBrush), Brushes.Black);
    public static readonly DependencyProperty CenterBrushProperty = BrushProperty(nameof(CenterBrush), Brushes.White);
    public static readonly DependencyProperty FocusRingBrushProperty = BrushProperty(nameof(FocusRingBrush), Brushes.Teal);

    public MinuteDial()
    {
        Focusable = true;
        Cursor = System.Windows.Input.Cursors.Hand;
        SnapsToDevicePixels = true;
    }

    public int Value
    {
        get => (int)GetValue(ValueProperty);
        set => SetValue(ValueProperty, value);
    }

    public Brush FaceBrush
    {
        get => (Brush)GetValue(FaceBrushProperty);
        set => SetValue(FaceBrushProperty, value);
    }

    public Brush DialBorderBrush
    {
        get => (Brush)GetValue(DialBorderBrushProperty);
        set => SetValue(DialBorderBrushProperty, value);
    }

    public Brush TickBrush
    {
        get => (Brush)GetValue(TickBrushProperty);
        set => SetValue(TickBrushProperty, value);
    }

    public Brush HandBrush
    {
        get => (Brush)GetValue(HandBrushProperty);
        set => SetValue(HandBrushProperty, value);
    }

    public Brush TextBrush
    {
        get => (Brush)GetValue(TextBrushProperty);
        set => SetValue(TextBrushProperty, value);
    }

    public Brush CenterBrush
    {
        get => (Brush)GetValue(CenterBrushProperty);
        set => SetValue(CenterBrushProperty, value);
    }

    public Brush FocusRingBrush
    {
        get => (Brush)GetValue(FocusRingBrushProperty);
        set => SetValue(FocusRingBrushProperty, value);
    }

    protected override Size MeasureOverride(Size availableSize)
    {
        const double preferredSize = 250;
        var width = double.IsInfinity(availableSize.Width) ? preferredSize : Math.Min(preferredSize, availableSize.Width);
        var height = double.IsInfinity(availableSize.Height) ? preferredSize : Math.Min(preferredSize, availableSize.Height);
        return new Size(width, height);
    }

    protected override AutomationPeer OnCreateAutomationPeer() => new MinuteDialAutomationPeer(this);

    protected override void OnRender(DrawingContext drawingContext)
    {
        base.OnRender(drawingContext);

        var size = Math.Min(ActualWidth, ActualHeight);
        if (size <= 24) return;

        var dpi = VisualTreeHelper.GetDpi(this).PixelsPerDip;
        var center = new Point(ActualWidth / 2, ActualHeight / 2);
        var radius = (size / 2) - 8;
        var borderPen = new Pen(DialBorderBrush, IsKeyboardFocused ? 3 : 2);
        drawingContext.DrawEllipse(FaceBrush, borderPen, center, radius, radius);

        if (IsKeyboardFocused)
        {
            drawingContext.DrawEllipse(null, new Pen(FocusRingBrush, 2), center, radius - 5, radius - 5);
        }

        DrawTicks(drawingContext, center, radius);
        DrawLabels(drawingContext, center, radius, dpi);
        DrawHand(drawingContext, center, radius);
    }

    protected override void OnMouseLeftButtonDown(MouseButtonEventArgs e)
    {
        base.OnMouseLeftButtonDown(e);
        Focus();
        CaptureMouse();
        UpdateValueFromPoint(e.GetPosition(this));
        e.Handled = true;
    }

    protected override void OnMouseMove(MouseEventArgs e)
    {
        base.OnMouseMove(e);
        if (!IsMouseCaptured || e.LeftButton != MouseButtonState.Pressed) return;

        UpdateValueFromPoint(e.GetPosition(this));
        e.Handled = true;
    }

    protected override void OnMouseLeftButtonUp(MouseButtonEventArgs e)
    {
        base.OnMouseLeftButtonUp(e);
        if (!IsMouseCaptured) return;

        UpdateValueFromPoint(e.GetPosition(this));
        ReleaseMouseCapture();
        e.Handled = true;
    }

    protected override void OnMouseWheel(MouseWheelEventArgs e)
    {
        base.OnMouseWheel(e);
        ChangeValue(e.Delta > 0 ? 1 : -1);
        e.Handled = true;
    }

    protected override void OnKeyDown(KeyEventArgs e)
    {
        base.OnKeyDown(e);
        switch (e.Key)
        {
            case Key.Up:
            case Key.Right:
                ChangeValue(1);
                break;
            case Key.Down:
            case Key.Left:
                ChangeValue(-1);
                break;
            case Key.PageUp:
                ChangeValue(5);
                break;
            case Key.PageDown:
                ChangeValue(-5);
                break;
            case Key.Home:
                SetCurrentValue(ValueProperty, 1);
                break;
            case Key.End:
                SetCurrentValue(ValueProperty, 60);
                break;
            default:
                return;
        }

        e.Handled = true;
    }

    protected override void OnGotKeyboardFocus(KeyboardFocusChangedEventArgs e)
    {
        base.OnGotKeyboardFocus(e);
        InvalidateVisual();
    }

    protected override void OnLostKeyboardFocus(KeyboardFocusChangedEventArgs e)
    {
        base.OnLostKeyboardFocus(e);
        InvalidateVisual();
    }

    private static DependencyProperty BrushProperty(string name, Brush defaultValue) => DependencyProperty.Register(
        name,
        typeof(Brush),
        typeof(MinuteDial),
        new FrameworkPropertyMetadata(defaultValue, FrameworkPropertyMetadataOptions.AffectsRender));

    private void DrawTicks(DrawingContext drawingContext, Point center, double radius)
    {
        for (var minute = 0; minute < 60; minute++)
        {
            var isMajor = minute % 5 == 0;
            var angle = minute * 6 * Math.PI / 180;
            var outer = PointOnCircle(center, radius - 10, angle);
            var inner = PointOnCircle(center, radius - (isMajor ? 22 : 16), angle);
            var pen = new Pen(TickBrush, isMajor ? 2.2 : 1);
            pen.StartLineCap = PenLineCap.Round;
            pen.EndLineCap = PenLineCap.Round;
            drawingContext.DrawLine(pen, inner, outer);
        }
    }

    private void DrawLabels(DrawingContext drawingContext, Point center, double radius, double dpi)
    {
        foreach (var value in new[] { 60, 15, 30, 45 })
        {
            var angle = (value % 60) * 6 * Math.PI / 180;
            var position = PointOnCircle(center, radius - 37, angle);
            var text = CreateText(value.ToString(CultureInfo.CurrentCulture), 12, FontWeights.SemiBold, dpi);
            drawingContext.DrawText(text, new Point(position.X - text.Width / 2, position.Y - text.Height / 2));
        }
    }

    private void DrawHand(DrawingContext drawingContext, Point center, double radius)
    {
        var angle = (Value % 60) * 6 * Math.PI / 180;
        var handEnd = PointOnCircle(center, radius * 0.57, angle);
        var handPen = new Pen(HandBrush, 5)
        {
            StartLineCap = PenLineCap.Round,
            EndLineCap = PenLineCap.Round
        };
        drawingContext.DrawLine(handPen, center, handEnd);
        drawingContext.DrawEllipse(CenterBrush, new Pen(HandBrush, 3), center, 8, 8);
    }

    private FormattedText CreateText(string value, double size, FontWeight weight, double dpi) => new(
        value,
        CultureInfo.CurrentUICulture,
        System.Windows.FlowDirection.LeftToRight,
        new Typeface(new FontFamily("Segoe UI"), FontStyles.Normal, weight, FontStretches.Normal),
        size,
        TextBrush,
        dpi);

    private static Point PointOnCircle(Point center, double radius, double clockwiseAngle) => new(
        center.X + Math.Sin(clockwiseAngle) * radius,
        center.Y - Math.Cos(clockwiseAngle) * radius);

    private void UpdateValueFromPoint(Point point)
    {
        var center = new Point(ActualWidth / 2, ActualHeight / 2);
        var deltaX = point.X - center.X;
        var deltaY = point.Y - center.Y;
        if (Math.Sqrt(deltaX * deltaX + deltaY * deltaY) < 12) return;

        var clockwiseAngle = Math.Atan2(deltaX, -deltaY);
        if (clockwiseAngle < 0) clockwiseAngle += Math.PI * 2;

        var minute = (int)Math.Round(clockwiseAngle / (Math.PI * 2) * 60);
        SetCurrentValue(ValueProperty, minute == 0 ? 60 : minute);
    }

    private void ChangeValue(int difference) =>
        SetCurrentValue(ValueProperty, Math.Clamp(Value + difference, 1, 60));

    private sealed class MinuteDialAutomationPeer : FrameworkElementAutomationPeer, IRangeValueProvider
    {
        private readonly MinuteDial _dial;

        public MinuteDialAutomationPeer(MinuteDial owner) : base(owner) => _dial = owner;

        public bool IsReadOnly => false;
        public double LargeChange => 5;
        public double Maximum => 60;
        public double Minimum => 1;
        public double SmallChange => 1;
        public double Value => _dial.Value;

        protected override string GetClassNameCore() => nameof(MinuteDial);

        protected override AutomationControlType GetAutomationControlTypeCore() => AutomationControlType.Slider;

        public override object GetPattern(PatternInterface patternInterface) =>
            patternInterface == PatternInterface.RangeValue ? this : base.GetPattern(patternInterface);

        public void SetValue(double value)
        {
            if (!_dial.IsEnabled) throw new ElementNotEnabledException();
            if (double.IsNaN(value) || double.IsInfinity(value)) throw new ArgumentOutOfRangeException(nameof(value));

            var minute = Math.Clamp((int)Math.Round(value), 1, 60);
            _dial.Dispatcher.Invoke(() => _dial.SetCurrentValue(ValueProperty, minute));
        }
    }
}
