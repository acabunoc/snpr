class SnpsController < ApplicationController
  helper_method :sort_column, :sort_direction
	def index
		@snps = Snp.paginate(:page => params[:page])

		respond_to do |format|
			format.html
			format.xml 
		end
	end
	
	def show
		@snp = Snp.find_by_id(params[:id])
		@users = User.find(:all, :conditions => { :user_snp => { :snps => { :id => @snp.id }}}, :joins => [ :user_snps => :snp])
    @total_genotypes = 0
    @snp.genotype_frequency.each do |key,value|
      @total_genotypes += value
    end
    
    @total_alleles = 0
    @snp.allele_frequency.each do |key,value|
      @total_alleles += value
    end
    
    Resque.enqueue(Plos,@snp)
    Resque.enqueue(Mendeley,@snp)
	  Resque.enqueue(Snpedia,@snp)
	  
	  @plos_papers = @snp.plos_paper.order(sort_column + " " + sort_direction)
	  @page_plos_papers = @plos_papers.paginate(:page => params[:page],:per_page => 4)
	  
		respond_to do |format|
			format.html
			format.xml
		end
	end
	
	private
	
	def sort_column
    PlosPaper.column_names.include?(params[:sort]) ? params[:sort] : "pub_date"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end