class EntriesController < ApplicationController
  before_action :logged_in_user
  before_action :set_live
  before_action :future_live

  def new
    @song = @live.songs.build
    @song.playings.build
  end

  def create
    @song = @live.songs.build(song_params)
    return render :new unless @song.save
    if @song.send_entry(current_user, params[:notes])
      flash[:info] = '曲の申請メールを送信しました'
    else
      flash[:danger] = 'メールの送信に失敗しました'
    end
    redirect_to @song.live
  end

  private

  def set_live
    @live = Live.find(params[:live_id])
  end

  def future_live
    redirect_to root_url if @live.date <= Date.today
  end

  def song_params
    params.require(:song).permit(:name, :artist, :status, playings_attributes: %i[id user_id inst])
  end
end
