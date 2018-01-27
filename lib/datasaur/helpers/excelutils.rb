# excel_utils.rb

require 'rubyXL'

class ExcelIO
  def initialize(owner, sheetname: nil)
    @time          = Time.now.strftime "%Y-%m-%d_%H-%M-%S"
    @path          = File.expand_path('~/Documents/Jeyaraj/My_Contents/Work/Commercial/Reports')
    @report_path   = File.join(@path, "Tech_Trending_#{owner.to_s}_#{@time}.xlsx")
    @template_path = File.join(@path, 'Tech_Trend_Template.xlsx')
    @wb            = RubyXL::Parser.parse(@template_path)
    @ws            = sheetname.nil? ? @wb.worksheets[0] : @wb[sheetname]
  end

  def write_cell(config)
    @ws.add_cell(config.row, config.col, config.val)
    cell = @ws[config.row][config.col]
    cell.set_number_format '#,###;[Red] (#,###);0'
    cell.change_font_name('Arial')
  end

  def save
    @wb.write(@template_path)
  end
end


class CellConfig

  attr_reader :row, :col, :val

  def initialize(address, val)
    @address = address
    @val     = val
    @row     = RubyXL::Reference.ref2ind(@address).first
    @col     = RubyXL::Reference.ref2ind(@address).last
  end
end
