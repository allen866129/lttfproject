# encoding: UTF-8”
ActiveAdmin.register User do
  config.sort_order = "id_asc"
  index do
  	column :id
    column :username
    column :email
    column :fbaccount 
    column :roles do |user|
      user.roles.collect {|c| c.name.capitalize }.to_sentence    
    end
    actions
  end
  
  show do |ad|
    attributes_table do
      row :id
      row :username
      row :email
      row :fbaccount
      row :playerphoto 
      row :roles do |user|
      	user.roles.collect {|r| r.name.capitalize }.to_sentence
      end
    end      
  end

  form(:html => { :multipart => true }) do |f|
    f.inputs "User Details" do
      f.input :id, input_html: { disabled: true }
      f.input :username, input_html: { disabled: true }
      f.input :email
      f.input :fbaccount
      f.input :roles, :collection => Role.global,
        :label_method => lambda { |el| t "simple_form.options.user.roles.#{el.name}" }

      #f.input :playerphoto, :as => :file, :label => "舊有照片", :hint => f.template.image_tag(f.object.playerphoto.url(:thumb)), input_html: { disabled: true }
      #f.input :playerphoto, :as => :file, :label => "更新照片"
      f.input :playerphoto, :image_preview => true, :input_html => {:onchange => "readURL(this)"}
    end
  
   f.inputs "playerprofiel Information", for: [:playerprofile, f.object.playerprofile] do |p|
      p.input :curscore 
      p.input :initscore 
      p.input :totalwongames
      p.input :totallosegames
      p.input :lastgamedate
      p.input :lastgamename
      p.input :lastscoreupdatedate
      p.input :gamehistory
      p.input :bio
      p.input :paddleholdtype
      p.input :paddlemodel
      p.input :forwardrubber
      p.input :backrubber
      p.input :created_at
      p.input :updated_at
      p.actions
    end
    f.actions

  end
  controller do  	
    def update
    	params[:user].each{|k,v| resource.send("#{k}=",v)}  		
  		super  		
  	end
 
    
  end
end
