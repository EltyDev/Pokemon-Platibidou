module BattleEngine
	module_function
  def s_heal_max(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(target, skill)
    if(target.battle_effect.has_heal_block_effect?)
      _mp([:msg, parse_text_with_pokemon(19,890, target)])
      return
    elsif(target.hp == target.max_hp)
      _mp(MSG_Fail)
      return
    # Heal Pulse fails if the target has a substitute
    elsif(target.battle_effect.has_substitute_effect? && skill.id == 505)
      _mp(MSG_Fail)
      return
    end
    # Vibra Soin & Méga Blaster
    if skill.id == 505 && Abilities.has_ability_usable(launcher, 177)
      hp = target.max_hp * 3 / 4
    else
      hp = target.max_hp
    end
    _message_stack_push([:hp_up, target, hp])
    _message_stack_push([:msg, parse_text_with_pokemon(19, 387, target)])
  end

  def s_thune(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    $pokemon_party.money += $pokemon_party.money + 10000
    return _msgp(18, 288)
  end
  
  def s_obj(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    $bag.add_item(2, 10)
    $bag.add_item(23 , 10)
    return _msgp(18, 289)
  end
  
  def s_thune_obj(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    $pokemon_party.money += $pokemon_party.money + 100000
    $bag.add_item(2, 30)
    $bag.add_item(23 , 10)
    $bag.add_item(50 , 5)
    return _msgp(18, 290)
  end

  def s_worthit(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    $bag.add_item(1, 1)
    _msgp(18, 291)
    __s_hp_down_check(Float::INFINITY , launcher)
    return true
  end
end