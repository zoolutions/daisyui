# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::ClassGroupUtils, "class map" do
  let(:class_utils) { described_class.new(DaisyUI::ClassMerge::TailwindConfig::DEFAULTS) }
  let(:class_map)   { class_utils.class_map }

  def class_groups_in_class_part(class_part)
    class_group_id = class_part[:class_group_id]
    validators = class_part[:validators]
    next_part = class_part[:next_part]

    class_groups = Set.new

    class_groups.add(class_group_id) if class_group_id

    validators.each do |validator|
      class_groups.add(validator[:class_group_id])
    end

    next_part.each_value do |next_class_part|
      class_groups_in_class_part(next_class_part).each do |class_group|
        class_groups.add(class_group)
      end
    end

    class_groups
  end

  it "class map has correct class groups at first part" do
    result = {}

    class_map[:next_part].each do |key, value|
      result[key] = class_groups_in_class_part(value).to_a.sort
    end

    expect(class_map[:class_group_id]).to be_falsey
    expect(class_map[:validators].map { |v| v[:class_group_id] }).to eq(["container-named"])

    result = result.sort.to_h

    expect(result).to eq({
      "@container" => ["container-type"],
      "absolute" => ["position"],
      "accent" => ["accent"],
      "align" => ["vertical-align"],
      "animate" => ["animate"],
      "antialiased" => ["font-smoothing"],
      "appearance" => ["appearance"],
      "aspect" => ["aspect"],
      "auto" => %w[auto-cols auto-rows],
      "backdrop" => %w[
        backdrop-blur
        backdrop-brightness
        backdrop-contrast
        backdrop-filter
        backdrop-grayscale
        backdrop-hue-rotate
        backdrop-invert
        backdrop-opacity
        backdrop-saturate
        backdrop-sepia
      ],
      "backface" => ["backface"],
      "basis" => ["basis"],
      "bg" =>
          %w[
            bg-attachment
            bg-blend
            bg-clip
            bg-color
            bg-image
            bg-origin
            bg-position
            bg-repeat
            bg-size
          ],
      "block" => %w[block-size display],
      "blur" => ["blur"],
      "border" =>
          [
            "border-collapse",
            "border-color",
            "border-color-b",
            "border-color-be",
            "border-color-bs",
            "border-color-e",
            "border-color-l",
            "border-color-r",
            "border-color-s",
            "border-color-t",
            "border-color-x",
            "border-color-y",
            "border-spacing",
            "border-spacing-x",
            "border-spacing-y",
            "border-style",
            "border-w",
            "border-w-b",
            "border-w-be",
            "border-w-bs",
            "border-w-e",
            "border-w-l",
            "border-w-r",
            "border-w-s",
            "border-w-t",
            "border-w-x",
            "border-w-y"
          ],
      "bottom" => ["bottom"],
      "box" => %w[box box-decoration],
      "break" => %w[break break-after break-before break-inside],
      "brightness" => ["brightness"],
      "capitalize" => ["text-transform"],
      "caption" => ["caption"],
      "caret" => ["caret-color"],
      "clear" => ["clear"],
      "col" => %w[col-end col-start col-start-end],
      "collapse" => ["visibility"],
      "columns" => ["columns"],
      "container" => ["container"],
      "content" => %w[align-content content],
      "contents" => ["display"],
      "contrast" => ["contrast"],
      "cursor" => ["cursor"],
      "decoration" => %w[text-decoration-color text-decoration-style text-decoration-thickness],
      "delay" => ["delay"],
      "diagonal" => ["fvn-fraction"],
      "divide" => [
        "divide-color",
        "divide-style",
        "divide-x",
        "divide-x-reverse",
        "divide-y",
        "divide-y-reverse"
      ],
      "drop" => %w[drop-shadow drop-shadow-color],
      "duration" => ["duration"],
      "ease" => ["ease"],
      "end" => ["end"],
      "field" => ["field-sizing"],
      "fill" => ["fill"],
      "filter" => ["filter"],
      "fixed" => ["position"],
      "flex" => %w[display flex flex-direction flex-wrap],
      "float" => ["float"],
      "flow" => ["display"],
      "font" => %w[font-family font-features font-stretch font-weight],
      "forced" => ["forced-color-adjust"],
      "from" => %w[gradient-from gradient-from-pos],
      "gap" => %w[gap gap-x gap-y],
      "grayscale" => ["grayscale"],
      "grid" => %w[display grid-cols grid-flow grid-rows],
      "grow" => ["grow"],
      "h" => ["h"],
      "hidden" => ["display"],
      "hue" => ["hue-rotate"],
      "hyphens" => ["hyphens"],
      "indent" => ["indent"],
      "inline" => %w[display inline-size],
      "inset" => %w[
        end
        inset
        inset-be
        inset-bs
        inset-ring-color
        inset-ring-w
        inset-shadow
        inset-shadow-color
        inset-x
        inset-y
        start
      ],
      "invert" => ["invert"],
      "invisible" => ["visibility"],
      "isolate" => ["isolation"],
      "isolation" => ["isolation"],
      "italic" => ["font-style"],
      "items" => ["align-items"],
      "justify" => %w[justify-content justify-items justify-self],
      "leading" => ["leading"],
      "left" => ["left"],
      "line" => %w[line-clamp text-decoration],
      "lining" => ["fvn-figure"],
      "list" => %w[display list-image list-style-position list-style-type],
      "lowercase" => ["text-transform"],
      "m" => ["m"],
      "mask" => [
        "mask-clip",
        "mask-composite",
        "mask-image",
        "mask-image-b-from-color",
        "mask-image-b-from-pos",
        "mask-image-b-to-color",
        "mask-image-b-to-pos",
        "mask-image-conic-from-color",
        "mask-image-conic-from-pos",
        "mask-image-conic-pos",
        "mask-image-conic-to-color",
        "mask-image-conic-to-pos",
        "mask-image-l-from-color",
        "mask-image-l-from-pos",
        "mask-image-l-to-color",
        "mask-image-l-to-pos",
        "mask-image-linear-from-color",
        "mask-image-linear-from-pos",
        "mask-image-linear-pos",
        "mask-image-linear-to-color",
        "mask-image-linear-to-pos",
        "mask-image-r-from-color",
        "mask-image-r-from-pos",
        "mask-image-r-to-color",
        "mask-image-r-to-pos",
        "mask-image-radial",
        "mask-image-radial-from-color",
        "mask-image-radial-from-pos",
        "mask-image-radial-pos",
        "mask-image-radial-shape",
        "mask-image-radial-size",
        "mask-image-radial-to-color",
        "mask-image-radial-to-pos",
        "mask-image-t-from-color",
        "mask-image-t-from-pos",
        "mask-image-t-to-color",
        "mask-image-t-to-pos",
        "mask-image-x-from-color",
        "mask-image-x-from-pos",
        "mask-image-x-to-color",
        "mask-image-x-to-pos",
        "mask-image-y-from-color",
        "mask-image-y-from-pos",
        "mask-image-y-to-color",
        "mask-image-y-to-pos",
        "mask-mode",
        "mask-origin",
        "mask-position",
        "mask-repeat",
        "mask-size",
        "mask-type"
      ],
      "max" => %w[max-block-size max-h max-inline-size max-w],
      "mb" => ["mb"],
      "mbe" => ["mbe"],
      "mbs" => ["mbs"],
      "me" => ["me"],
      "min" => %w[min-block-size min-h min-inline-size min-w],
      "mix" => ["mix-blend"],
      "ml" => ["ml"],
      "mr" => ["mr"],
      "ms" => ["ms"],
      "mt" => ["mt"],
      "mx" => ["mx"],
      "my" => ["my"],
      "no" => ["text-decoration"],
      "normal" => %w[fvn-normal text-transform],
      "not" => %w[font-style sr],
      "object" => %w[object-fit object-position],
      "oldstyle" => ["fvn-figure"],
      "opacity" => ["opacity"],
      "order" => ["order"],
      "ordinal" => ["fvn-ordinal"],
      "origin" => ["transform-origin"],
      "outline" => %w[outline-color outline-offset outline-style outline-w],
      "overflow" => %w[overflow overflow-x overflow-y],
      "overline" => ["text-decoration"],
      "overscroll" => %w[overscroll overscroll-x overscroll-y],
      "p" => ["p"],
      "pb" => ["pb"],
      "pbe" => ["pbe"],
      "pbs" => ["pbs"],
      "pe" => ["pe"],
      "perspective" => %w[perspective perspective-origin],
      "pl" => ["pl"],
      "place" => %w[place-content place-items place-self],
      "placeholder" => ["placeholder-color"],
      "pointer" => ["pointer-events"],
      "pr" => ["pr"],
      "proportional" => ["fvn-spacing"],
      "ps" => ["ps"],
      "pt" => ["pt"],
      "px" => ["px"],
      "py" => ["py"],
      "relative" => ["position"],
      "resize" => ["resize"],
      "right" => ["right"],
      "ring" => ["ring-color", "ring-offset-color", "ring-offset-w", "ring-w", "ring-w-inset"],
      "rotate" => %w[rotate rotate-x rotate-y rotate-z],
      "rounded" => %w[
        rounded
        rounded-b
        rounded-bl
        rounded-br
        rounded-e
        rounded-ee
        rounded-es
        rounded-l
        rounded-r
        rounded-s
        rounded-se
        rounded-ss
        rounded-t
        rounded-tl
        rounded-tr
      ],
      "row" => %w[row-end row-start row-start-end],
      "saturate" => ["saturate"],
      "scale" => %w[scale scale-3d scale-x scale-y scale-z],
      "scheme" => ["color-scheme"],
      "scroll" => %w[
        scroll-behavior
        scroll-m
        scroll-mb
        scroll-mbe
        scroll-mbs
        scroll-me
        scroll-ml
        scroll-mr
        scroll-ms
        scroll-mt
        scroll-mx
        scroll-my
        scroll-p
        scroll-pb
        scroll-pbe
        scroll-pbs
        scroll-pe
        scroll-pl
        scroll-pr
        scroll-ps
        scroll-pt
        scroll-px
        scroll-py
      ],
      "scrollbar" => %w[
        scrollbar-gutter
        scrollbar-thumb-color
        scrollbar-track-color
        scrollbar-w
      ],
      "select" => ["select"],
      "self" => ["align-self"],
      "sepia" => ["sepia"],
      "shadow" => %w[shadow shadow-color],
      "shrink" => ["shrink"],
      "size" => ["size"],
      "skew" => %w[skew skew-x skew-y],
      "slashed" => ["fvn-slashed-zero"],
      "snap" => %w[snap-align snap-stop snap-strictness snap-type],
      "space" => ["space-x", "space-x-reverse", "space-y", "space-y-reverse"],
      "sr" => ["sr"],
      "stacked" => ["fvn-fraction"],
      "start" => ["start"],
      "static" => ["position"],
      "sticky" => ["position"],
      "stroke" => %w[stroke stroke-w],
      "subpixel" => ["font-smoothing"],
      "tab" => ["tab-size"],
      "table" => %w[display table-layout],
      "tabular" => ["fvn-spacing"],
      "text" => %w[
        font-size
        text-alignment
        text-color
        text-overflow
        text-shadow
        text-shadow-color
        text-wrap
      ],
      "to" => %w[gradient-to gradient-to-pos],
      "top" => ["top"],
      "touch" => %w[touch touch-pz touch-x touch-y],
      "tracking" => ["tracking"],
      "transform" => %w[transform transform-style],
      "transition" => %w[transition transition-behavior],
      "translate" => %w[translate translate-none translate-x translate-y translate-z],
      "truncate" => ["text-overflow"],
      "underline" => %w[text-decoration underline-offset],
      "uppercase" => ["text-transform"],
      "via" => %w[gradient-via gradient-via-pos],
      "visible" => ["visibility"],
      "w" => ["w"],
      "whitespace" => ["whitespace"],
      "will" => ["will-change"],
      "wrap" => ["wrap"],
      "z" => ["z"],
      "zoom" => ["zoom"]
    }
                        )
  end
end
