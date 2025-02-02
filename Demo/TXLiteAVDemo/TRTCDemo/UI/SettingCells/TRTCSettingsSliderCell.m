/*
 * Module:   TRTCSettingsSliderCell
 *
 * Function: 配置列表Cell，右侧是一个Slider
 *
 */

#import "TRTCSettingsSliderCell.h"

#import "Masonry.h"
#import "UILabel+TRTC.h"
#import "UISlider+TRTC.h"

@interface TRTCSettingsSliderCell ()

@property(strong, nonatomic) UISlider *         slider;
@property(strong, nonatomic) UILabel *          valueLabel;
@property(strong, nonatomic) NSNumberFormatter *numFormatter;

@end

@implementation TRTCSettingsSliderCell

- (void)setupUI {
    [super setupUI];

    self.slider = [UISlider trtc_slider];
    [self.slider addTarget:self action:@selector(onSliderValueChange:forEvent:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.slider];

    self.valueLabel                           = [UILabel trtc_contentLabel];
    self.valueLabel.textAlignment             = NSTextAlignmentRight;
    self.valueLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.valueLabel];

    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.valueLabel.mas_leading).offset(-5);
        make.width.mas_equalTo(180);
    }];

    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-18);
        make.width.mas_equalTo(36);
    }];

    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(9);
        make.top.equalTo(self.contentView).offset(15);
    }];

    self.numFormatter                       = [[NSNumberFormatter alloc] init];
    self.numFormatter.minimumFractionDigits = 0;
    self.numFormatter.maximumFractionDigits = 1;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.item removeObserver:self forKeyPath:@"sliderValue"];
}

- (void)dealloc {
    [self.item removeObserver:self forKeyPath:@"sliderValue"];
}

- (void)didUpdateItem:(TRTCSettingsBaseItem *)item {
    if ([item isKindOfClass:[TRTCSettingsSliderItem class]]) {
        TRTCSettingsSliderItem *sliderItem = (TRTCSettingsSliderItem *)item;
        if (0 == sliderItem.step) sliderItem.step = 1.f;
        self.slider.minimumValue = sliderItem.minValue / sliderItem.step;
        self.slider.maximumValue = sliderItem.maxValue / sliderItem.step;
        self.slider.value        = sliderItem.sliderValue / sliderItem.step;
        self.slider.continuous   = sliderItem.continuous;
        self.valueLabel.text     = [self.numFormatter stringFromNumber:@(sliderItem.sliderValue)];
    }

    [item addObserver:self forKeyPath:@"sliderValue" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"sliderValue"]) {
        TRTCSettingsSliderItem *item = (TRTCSettingsSliderItem *)self.item;
        if (0 == item.step) item.step = 1.f;
        self.slider.value    = item.sliderValue / item.step;
        self.valueLabel.text = [self.numFormatter stringFromNumber:@(item.sliderValue)];
    }
}

- (void)onSliderValueChange:(UISlider *)slider forEvent:(UIEvent *)event {
    UITouch *touchEvent = [[event allTouches] anyObject];

    TRTCSettingsSliderItem *sliderItem = (TRTCSettingsSliderItem *)self.item;
    float                   value      = slider.value * sliderItem.step;
    self.valueLabel.text               = [self.numFormatter stringFromNumber:@(value)];

    switch (touchEvent.phase) {
        case UITouchPhaseEnded:
            sliderItem.sliderValue = value;
            sliderItem.action(value);
            break;
        default:
            break;
    }
}

@end

@implementation TRTCSettingsSliderItem

- (instancetype)initWithTitle:(NSString *)title value:(float)value min:(float)min max:(float)max step:(float)step continuous:(BOOL)continuous action:(void (^)(float))action {
    if (self = [super init]) {
        self.title   = title;
        _sliderValue = value;
        _minValue    = min;
        _maxValue    = max;
        _step        = step == 0 ? 1 : step;
        _continuous  = continuous;
        _action      = action;
    }
    return self;
}

+ (Class)bindedCellClass {
    return [TRTCSettingsSliderCell class];
}

- (NSString *)bindedCellId {
    return [TRTCSettingsSliderItem bindedCellId];
}

@end
