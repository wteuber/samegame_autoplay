class SameGameHelper
  def self.generate_matrix_string(params = {})
    matrix = SameGameHelper::generate_matrix(params)
    '[['+matrix.map{|rows| rows*','}*'],['+']]'
  end

  def self.generate_matrix(params = {})
    cols = params[:cols] || 10
    rows = params[:rows] || 10
    colors = params[:colors] || 3
    
    1.upto(cols).map{1.upto(rows).map{rand(colors)+1}}
  end
end
