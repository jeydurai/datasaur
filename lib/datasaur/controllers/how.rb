# how.rb
# How functionalities

class HowIs
  def initialize node, mongo_opts, for_years, args
    @node       = node
    @mongo_opts = mongo_opts
    @for_years  = for_years
    @args       = args
  end

  def tellme
    1
  end
end
