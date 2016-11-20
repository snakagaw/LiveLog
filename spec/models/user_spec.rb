require 'rails_helper'

RSpec.describe User, type: :model do

  before do
    @user = User.new(last_name: '京大',
                     first_name: 'アンプラ太郎',
                     furigana: 'きょうだい あんぷらたろう',
                     nickname: 'アンプラ',
                     email: 'livelog@ku-unplugged.net',
                     joined: '2011-06-01',
                     password: 'foobar',
                     password_confirmation: 'foobar')
  end

  subject { @user }

  it { is_expected.to respond_to(:first_name) }
  it { is_expected.to respond_to(:last_name) }
  it { is_expected.to respond_to(:furigana) }
  it { is_expected.to respond_to(:nickname) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:joined) }
  it { is_expected.to respond_to(:password_digest) }
  it { is_expected.to respond_to(:password) }
  it { is_expected.to respond_to(:password_confirmation) }
  it { is_expected.to respond_to(:authenticate) }

  it { is_expected.to be_valid }

  describe 'when first name is not present' do
    before { @user.first_name = '' }
    it { is_expected.not_to be_valid }
  end

  describe 'when last name is not present' do
    before { @user.last_name = '' }
    it { is_expected.not_to be_valid }
  end

  describe 'when furigana is not present' do
    before { @user.furigana = '' }
    it { is_expected.not_to be_valid }
  end

  describe 'when joined is not present' do
    before { @user.joined = '' }
    it { is_expected.not_to be_valid }
  end

  describe 'when nickname is too long' do
    before { @user.nickname = 'a' * 51 }
    it { is_expected.not_to be_valid }
  end

  describe 'when email is too long' do
    before { @user.email = 'a' * 244 + '@ku-unplugged.net' }
    it { is_expected.not_to be_valid }
  end

  describe 'when email format is invalid' do
    it 'should be invalid' do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe 'when email format is valid' do
    it 'should be valid' do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe 'when email address is already taken' do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { is_expected.not_to be_valid }
  end

  describe 'email address with mixed case' do
    let(:mixed_case_email) { 'Foo@ExAMPle.CoM' }

    it 'should be saved as all lower-case' do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end

  describe 'when password is not present' do
    before do
      @user = User.new(last_name: '京大',
                       first_name: 'アンプラ太郎',
                       furigana: 'きょうだい あんぷらたろう',
                       joined: '2011-06-01',
                       password: ' ',
                       password_confirmation: ' ')
    end
    it { is_expected.not_to be_valid }
  end

  describe 'when password does not match confirmation' do
    before { @user.password_confirmation = 'mismatch' }
    it { is_expected.not_to be_valid }
  end

  describe 'when password is too short' do
    before { @user.password = @user.password_confirmation = 'a' * 5 }
    it { is_expected.not_to be_valid }
  end

  describe 'return value of authenticate method' do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe 'with valid password' do
      it { is_expected.to eq found_user.authenticate(@user.password) }
    end

    describe 'with invalid password' do
      let(:user_for_invalid_password) { found_user.authenticate('invalid') }

      it { is_expected.not_to eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_falsey }
    end
  end
end