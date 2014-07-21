require 'rspec'

class PermissionController #< ApplicationController
  def initialize(user, acc)
    @current_acc = acc
    @current_user = user
  end

  def index
    unless current_user.can_view?(current_acc)
      redirect_to root_path, flash: 'Not authorized for this action'
    end
    render_index
  end

  def render_index
    current_acc.get_all_members.each do |member|
      print member.get_name
      print ' '
      print current_acc.get_permission(member)
      print ' '
      print 'X' if current_user.can_change_permission?(current_acc, member)
      print "\n"
    end
  end

  private
  def current_user
    #User.find(cookies[:id])
    @current_user
  end

  def current_acc
    #Account.find(params[:account_id])
    @current_acc
  end
end

class Account
  def initialize(owner, members = {})
    @owner = owner
    @members = members
  end

  def get_permission(user)
    return :owner if owner?(user)
    return :admin if admin?(user)
    return :user if user?(user)
    :not_member
  end

  def owner?(user)
    user == @owner
  end

  def admin?(user)
    @members[:admins] != nil && @members[:admins].include?(user)
  end

  def user?(user)
    @members[:users] != nil && @members[:users].include?(user)
  end

  def member?(user)
    owner?(user) || admin?(user) || user?(user)
  end

  def get_all_members
    returned_members = Array.new
    returned_members.push(@owner)
    @members[:admins].each { |admin| returned_members.push(admin) }
    @members[:users].each { |user| returned_members.push(user) }
    returned_members
  end
end

class User
  def initialize(name)
    @name = name
  end

  def get_name
    @name
  end

  def can_change_permission?(account, user)
    return false if(self==user)
    return true if( account.owner?(self) )
    return true if( account.admin?(self) && !account.owner?(user) )
    return false
  end

  def can_view?(account)
    account.member?(self)
  end
end

describe User do
  it 'can view members' do
    owner = User.new('Marian Mojzis')
    user = User.new('Anton Lieskovsky')
    not_member = User.new('Dominik Czernanski')
    acc = Account.new(owner, admins: [], users: [user])
    expect(user.can_view?(acc)).to eq(true)
    expect(not_member.can_view?(acc)).to eq(false)
  end

  it 'can change permission of user' do
    admin = User.new('Marek Polakovicz')
    owner = User.new('Marian Mojzis')
    user = User.new('Anton Lieskovsky')
    not_member = User.new('Dominik Czernanski')
    account = Account.new(owner, admins: [admin],users: [user])

    expect(user.can_change_permission?(account,user)).to eq(false)
    expect(owner.can_change_permission?(account,user)).to eq(true)
    expect(admin.can_change_permission?(account,user)).to eq(true)
    expect(not_member.can_change_permission?(account,user)).to eq(false)
    expect(admin.can_change_permission?(account,admin)).to eq(false)
    expect(owner.can_change_permission?(account,owner)).to eq(false)
  end

  it 'should has correct name' do
    user = User.new('Anton Lieskovsky')
    expect(user.get_name).to eq('Anton Lieskovsky')
  end

end

describe Account do
  it 'returns member permission' do
    admin = User.new('Marek Polakovicz')
    owner = User.new('Marian Mojzis')
    user = User.new('Anton Lieskovsky')
    not_member = User.new('Dominik Czernanski')
    account = Account.new(owner, admins: [admin],users: [user])

    expect(account.get_permission(user)).to eq(:user)
    expect(account.get_permission(owner)).to eq(:owner)
    expect(account.get_permission(admin)).to eq(:admin)
    expect(account.get_permission(not_member)).to eq(:not_member)
  end
end

admin = User.new('Marek Polakovicz')
owner = User.new('Marian Mojzis')
user = User.new('Anton Lieskovsky')
not_member = User.new('Dominik Czernanski')
account = Account.new(owner, admins: [admin],users: [user])
controller = PermissionController.new(admin, account)
controller.index