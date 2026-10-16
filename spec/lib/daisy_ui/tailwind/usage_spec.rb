# frozen_string_literal: true

require "tmpdir"

RSpec.describe DaisyUI::Tailwind::Usage do
  subject(:usage) { described_class.new(%w[Badge Button Card Hero Loading Menu MenuItem Modal Navbar Tab Tabs Toast]) }

  describe "#references" do
    {
      "a kit call" => "Button(:primary) { \"Save\" }",
      "an instance" => "render Card.new(:border)",
      "the namespaced constant" => "class AppNavbar < DaisyUI::Navbar; end",
      "a kit call with symbol arguments and no parentheses" => "Badge :primary do\n  \"New\"\nend",
      "a kit call with only a block" => "Hero do |hero|\nend",
      "a kit call with a brace block" => "Modal { plain \"Hi\" }",
      "a kit call with keyword arguments and no parentheses" => "Toast class: \"toast-end\" do\nend",
      "a kit call with a positional argument and no parentheses" => "Button variant do\nend",
      "a kit call with positional arguments and no parentheses" => "Badge @kind, size",
      "a kit call with one positional argument and no parentheses" => "Toast notice",
      "a kit call with a string and no parentheses" => "Badge \"New\""
    }.each do |shape, source|
      it "finds #{shape}" do
        expect(usage.references(source).size).to eq(1)
      end
    end

    it "ignores full-line comments" do
      expect(usage.references("# Loading state shown until the frame loads\n  # Loading(:spinner)\n")).to be_empty
    end

    it "ignores each template language's comments, and only those" do
      expect(usage.references("<%# Loading(:spinner) %>\n# Toast()\n", kind: "erb")).to eq(%w[Toast])
      expect(usage.references("-# Loading(:spinner)\n#sidebar= render DaisyUI::Menu.new\n", kind: "haml")).to eq(%w[Menu])
      expect(usage.references("/ Loading(:spinner)\n#sidebar= render DaisyUI::Menu.new\n", kind: "slim")).to eq(%w[Menu])
    end

    it "ignores a name that starts a sentence" do
      expect(usage.references("p { \"Toast thousands of freelancers\" }\n<<~TEXT\n  Card your guests, then Modal them.\nTEXT")).to be_empty
    end

    it "ignores a name inside another identifier or constant path" do
      expect(usage.references("MyButton(:x)\nUI::Card(:y)\nMenuItems.new\n@tab = Tabs\nload(Loading)")).to be_empty
    end

    it "tells components with a shared prefix apart" do
      expect(usage.references("Tabs(:box) { |tabs| tabs.tab(\"One\") }\nMenuItem.new")).to eq(%w[MenuItem Tabs])
    end
  end

  describe "#scan" do
    let(:dir) { Dir.mktmpdir("daisyui-usage") }

    before do
      FileUtils.mkdir_p(File.join(dir, "views"))
      File.write(File.join(dir, "views", "home.rb"), "Button(:primary)\n")
      File.write(File.join(dir, "views", "show.html.erb"), "<%= render DaisyUI::Card.new %>\n")
      File.write(File.join(dir, "views", "list.haml"), "#nav= render DaisyUI::Menu.new\n")
      File.write(File.join(dir, "views", "app.js"), "Navbar()\n")
      File.write(File.join(dir, "toast.rb"), "Toast()\n")
    end

    after { FileUtils.rm_rf(dir) }

    it "reads the Ruby and templates under each directory, sorted" do
      expect(usage.scan([File.join(dir, "views")])).to eq(%w[Button Card Menu])
    end

    it "reads a single file" do
      expect(usage.scan([File.join(dir, "toast.rb")])).to eq(%w[Toast])
    end

    it "raises on a path that does not exist, rather than finding nothing" do
      expect { usage.scan([File.join(dir, "missing")]) }.to raise_error(ArgumentError, /missing/)
    end
  end
end
