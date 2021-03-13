//c2t hccs
//c2t

import <c2t_cartographyHunt.ash>
import <c2t_lib.ash>
import <canadv.ash>
import <c2t_hccs_aux.ash>


//aborts before doing test
boolean HALT_BEFORE_TEST = get_property("c2t_hccs_haltBeforeTest").to_boolean();
//prints modtrace before non-stat tests
boolean PRINT_MODTRACE = get_property("c2t_hccs_printModtrace").to_boolean();


//wtb enum
int TEST_HP = 1;
int TEST_MUS = 2;
int TEST_MYS = 3;
int TEST_MOX = 4;
int TEST_FAMILIAR = 5;
int TEST_WEAPON = 6;
int TEST_SPELL = 7;
int TEST_NONCOMBAT = 8;
int TEST_ITEM = 9;
int TEST_HOT_RES = 10;
int TEST_COIL_WIRE = 11;


string[12] TEST_NAME;
TEST_NAME[TEST_COIL_WIRE] = "Coil Wire";
TEST_NAME[TEST_HP] = "Donate Blood";
TEST_NAME[TEST_MUS] = "Feed The Children";
TEST_NAME[TEST_MYS] = "Build Playground Mazes";
TEST_NAME[TEST_MOX] = "Feed Conspirators";
TEST_NAME[TEST_ITEM] = "Make Margaritas";
TEST_NAME[TEST_HOT_RES] = "Clean Steam Tunnels";
TEST_NAME[TEST_FAMILIAR] = "Breed More Collies";
TEST_NAME[TEST_NONCOMBAT] = "Be a Living Statue";
TEST_NAME[TEST_WEAPON] = "Reduce Gazelle Population";
TEST_NAME[TEST_SPELL] = "Make Sausage";


int c2t_getEffect(effect eff,skill ski);
int c2t_getEffect(effect eff,skill ski,int min);
int c2t_getEffect(effect eff,item ite);
int c2t_getEffect(effect eff,item ite,int min);
boolean c2t_haveUse(skill ski);
boolean c2t_haveUse(skill ski,int min);
boolean c2t_haveUse(item ite);
boolean c2t_haveUse(item ite,int min);

void c2t_hccs_init();
void c2t_hccs_exit();
boolean c2t_hccs_pre_coil();
boolean c2t_hccs_buff_exp();
boolean c2t_hccs_levelup();
boolean c2t_hccs_all_the_buffs();
boolean c2t_hccs_semirare_item();
boolean c2t_hccs_love_potion(boolean useit);
boolean c2t_hccs_love_potion(boolean useit,boolean dumpit);
boolean c2t_hccs_pre_hp();
boolean c2t_hccs_pre_mus();
boolean c2t_hccs_pre_mys();
boolean c2t_hccs_pre_mox();
boolean c2t_hccs_pre_item();
boolean c2t_hccs_pre_hot_res();
boolean c2t_hccs_pre_familiar();
boolean c2t_hccs_pre_noncombat();
boolean c2t_hccs_pre_weapon();
boolean c2t_hccs_pre_spell();
void c2t_hccs_test_handler(int test);
//string c2t_hccs_test_name(int test);
boolean c2t_hccs_test_done(int test);
boolean c2t_hccs_do_test(int test);
void c2t_hccs_fights();
//boolean c2t_cartographyHunt(location loc,monster mon);
boolean c2t_hccs_wishFight(monster mon);
boolean c2t_hccs_wandererFight();
int c2t_hccs_tripleSize(int num);
int c2t_hccs_tripleSize() return c2t_hccs_tripleSize(1);
void c2t_hccs_pantagramming();


void main() {
	c2t_assert(my_path() == "Community Service","Not in Community Service. Aborting.");
	//c2t_assert(my_primestat() != $stat[moxie],'This is not yet able to handle moxie classes. Aborting.');

	try {
		c2t_hccs_init();
		
		// Default equipment. // bad idea to reset equipment like this on every run of script
		//maximize("mus,equip garbage shirt,-equip kramco",false);
		
		c2t_hccs_test_handler(TEST_COIL_WIRE);
		
		c2t_assert(my_turncount() >= 60,'Something went exceptionally wrong coiling wire.');

		//TODO maybe reorder stat tests based on hardest to achieve for a given class or mainstat
		print('Checking test ' + TEST_MOX + ': ' + TEST_NAME[TEST_MOX],'blue');
		if (!get_property('csServicesPerformed').contains_text(TEST_NAME[TEST_MOX])) {
			c2t_hccs_levelup();
			c2t_hccs_love_potion(true);
			c2t_hccs_fights();
			//abort('End of the road for now');
			c2t_hccs_test_handler(TEST_MOX);
		}
		
		c2t_hccs_test_handler(TEST_MUS);
		c2t_hccs_test_handler(TEST_MYS);
		c2t_hccs_test_handler(TEST_HP);

		//best time to open guild as SC if need be, or fish for wanderers, so warn and abort if < 93% spit
		if (/*my_primestat() != $stat[moxie] &&*/ get_property('camelSpit').to_int() < 93 && !get_property("_c2t_hccs_earlySpitWarn").to_boolean()) {
			set_property("_c2t_hccs_earlySpitWarn","true");
			abort('Camel spit only at '+get_property('camelSpit')+'%');
		}
		//so this doesn't warn if ran after using spit for weapon test
		set_property("_c2t_hccs_earlySpitWarn","true");

		c2t_hccs_test_handler(TEST_ITEM);
		c2t_hccs_test_handler(TEST_FAMILIAR);
		c2t_hccs_test_handler(TEST_HOT_RES);
		c2t_hccs_test_handler(TEST_NONCOMBAT);
		c2t_hccs_test_handler(TEST_WEAPON);		
		c2t_hccs_test_handler(TEST_SPELL);

		//final service here
		c2t_hccs_do_test(30);
		
		print('Should be done with the Community Service run','blue');
	}
	finally
		c2t_hccs_exit();
}

//gave up trying to play nice, so brute forcing with visit_url()s
void c2t_hccs_pantagramming() {
	if (item_amount($item[portable pantogram]) > 0 && item_amount($item[pantogram pants]) == 0) {
		//use item
		visit_url("inv_use.php?which=3&whichitem=9573&pwd="+my_hash(),false,true);
		//use(1,$item[portable pantogram]);
		int temp;
		switch (my_primestat()) {
			case $stat[muscle]:
				temp = 1;
				break;
			case $stat[mysticality]:
				temp = 2;
				break;
			case $stat[moxie]:
				temp = 3;
				break;
			default:
				abort("broken stat?");
		}
		//primestat,hot res,+mp,+spell,-combat
		/*if (handling_choice())
			run_choice(1,"e=1&s1=-2,0&s2=-2,0&s3=-1,0&m="+temp);
		else*/ //brute force
			visit_url("choice.php?pwd&whichchoice=1270&option=1&e=1&s1=-2,0&s2=-2,0&s3=-1,0&m="+temp,true,true);
		//so mafia knows and maximizer can use
		cli_execute("refresh all");
	}
}

//TODO genericise and move to lib
int c2t_hccs_tripleSize(int num) {
	if (have_effect($effect[Triple-Sized]) == 0 && num > 0) {
		if (get_property('_powerfulGloveBatteryPowerUsed').to_int() >= 100) {
			print("Powerful Glove depleted. Cannot triple size.","blue");
			return 0;
		}

		item temp = $item[none];
		if (!have_equipped($item[Powerful Glove])) {
			temp = equipped_item($slot[acc3]);
			equip($slot[acc3],$item[Powerful Glove]);
		}

		int count = 0;
		repeat
			use_skill(1,$skill[CHEAT CODE: Triple Size]);
		until (++count >= num || get_property('_powerfulGloveBatteryPowerUsed').to_int() >= 100);

		if (temp != $item[none])
			equip($slot[acc3],temp);
	}
	return have_effect($effect[Triple-Sized]);
}

boolean c2t_haveUse(item ite) {
	return c2t_haveUse(ite,1);
}
boolean c2t_haveUse(item ite,int min) {
	if (available_amount(ite) >= min) {
		use(min,ite);
		return true;
	}
	return false;
}

int c2t_getEffect(effect eff,skill ski) {
	return c2t_getEffect(eff,ski,1);	
}
int c2t_getEffect(effect eff,skill ski,int min) {
	//TODO find a more efficient way to do this
	while (have_effect(eff) < min && have_skill(ski))
		use_skill(ski);
	if (have_effect(eff) < min)
		abort("Unable to cast enough "+ski);
	return have_effect(eff);
}
int c2t_getEffect(effect eff,item ite) {
	return c2t_getEffect(eff,ite,1);
}
int c2t_getEffect(effect eff,item ite,int min) {
	//TODO find a more efficient way to do this
	//not going to allow repeated use of items for now
	if (have_effect(eff) < min) {
		if (item_amount(ite) == 0)
			retrieve_item(1,ite);//or maybe create() ?
		use(1,ite);
	}
	if (have_effect(eff) < min)
		print("Unable to use enough "+ite,"blue");
	return have_effect(eff);
}

boolean c2t_hccs_wishFight(monster mon) {
	c2t_setChoice(1387,3);//saber yr
	if (!c2t_wishFight(mon))
		return false;
	run_turn();
	//if (choice_follows_fight()) //saber force breaks this I think?
		run_choice(-1);//just in case
	c2t_setChoice(1387,0);//unset

	if (get_property("lastEncounter") != mon && get_property("lastEncounter") != "Using the Force")
		return false;
	return true;
}

/*
boolean c2t_cartographyHunt(location loc,monster mon) {
	if (have_skill($skill[Map the Monsters]) && get_property('mappingMonsters') == 'false' && get_property('_monstersMapped').to_int() < 3)
		use_skill(1,$skill[Map the Monsters]);
	//else
	//	abort("Unable to cast Map the Monsters");
	//buffer result;
	//result = visit_url("runskillz.php?action=Skillz&whichskill=7344&targetplayer=3286685&quantity=1&pwd="+my_hash(),false,true);
	//print("result of visit_url()","blue");
	//print(result);
	//print("THIS IS WHAT YOU'RE LOOKING FOR","blue");
	//wait(15);
	//abort("STOP");

	if (get_property('_latteDrinkUsed') == 'true')
		cli_execute('latte refill cinnamon pumpkin vanilla');

	c2t_setChoice(1387,3);//saber yr

	if (get_property('mappingMonsters') == 'true') {
		buffer buf;
		buf = visit_url(loc.to_url(),false,true);
		if (!buf.contains_text("Leading Yourself Right to Them"))
			abort("Wrong thing came up when using Map the Monsters at "+loc+" with "+mon);
		buf = visit_url("choice.php?pwd&whichchoice=1435&option=1&heyscriptswhatsupwinkwink="+mon.to_int(),true,true);
		if (!buf.contains_text("<b>Combat"))
			abort("Didn't enter combat using Map the Monsters at "+loc+" with "+mon);
		run_turn();
		run_choice(-1);
		c2t_setChoice(1387,0);
		if (get_property('mappingMonsters') == 'false')
			return true;
	}
	return false;
	/*
	adv1(loc,-1,"");
	if (!handling_choice()) abort("No choice?");
	if (last_choice() == 1435 && count(available_choice_options()) > 0) {
		visit_url("choice.php?pwd&whichchoice=1435&option=1&heyscriptswhatsupwinkwink="+mon.to_int(),true,true);
		if (get_property('_latteDrinkUsed') == 'false')
			use_skill(1,$skill[gulp latte]);
		use_skill(1,$skill[Use the Force]);
		if (!handling_choice()) abort("No choice?");
		if (last_choice() == 1410 && count(available_choice_options()) > 0)
			run_choice(3);
	}
	else
		abort("Failed to select the monster from choice");
	//
}*/


void c2t_hccs_test_handler(int test) {
	//wanderer fight(s) before prepping stuff
	//magic number here assuming using a turn for limerick dungeon semi-rare
	while (turns_played() > 61 && c2t_hccs_wandererFight());

	print('Checking test ' + test + ': ' + TEST_NAME[test],'blue');
	if (!get_property('csServicesPerformed').contains_text(TEST_NAME[test])) {
		print('Running pre-'+TEST_NAME[test]+' stuff...','blue');
		switch (test) {
			case TEST_HP:
				if (!c2t_hccs_pre_hp())
					abort('Pre-HP fail');
				break;
			case TEST_MUS:
				if (!c2t_hccs_pre_mus())
					abort('Pre-MUS fail');
				break;
			case TEST_MYS:
				if (!c2t_hccs_pre_mys())
					abort('Pre-MYS fail');
				break;
			case TEST_MOX:
				if (!c2t_hccs_pre_mox())
					abort('Pre-MOX fail');
				break;
			case TEST_FAMILIAR:
				if (!c2t_hccs_pre_familiar())
					abort('Pre-FAMILIAR fail');
				break;
			case TEST_WEAPON:
				if (!c2t_hccs_pre_weapon())
					abort('Pre-WEAPON fail');
				break;
			case TEST_SPELL:
				if (!c2t_hccs_pre_spell())
					abort('Pre-SPELL fail');
				break;
			case TEST_NONCOMBAT:
				if (!c2t_hccs_pre_noncombat())
					abort('Pre-NONCOMBAT fail');
				break;
			case TEST_ITEM:
				if (!c2t_hccs_pre_item())
					abort('Pre-ITEM fail');
				break;
			case TEST_HOT_RES:
				if (!c2t_hccs_pre_hot_res())
					abort('Pre-HOT_RES fail');
				break;
			case TEST_COIL_WIRE:
				if (!c2t_hccs_pre_coil())
					abort('Pre-COIL_WIRE fail');
				break;
			default:
				abort('Something went horribly wrong with test handler');
		}
		if (HALT_BEFORE_TEST)
			abort('Double-check test '+test+': '+TEST_NAME[test]);

		//waits here are probably temporary
		print(`Test {test}: {TEST_NAME[test]} should be the minimum of {test == TEST_COIL_WIRE?"60 turns":"1 turn"}. Will do the test in...`);
		wait(5);
		c2t_hccs_do_test(test);
		wait(3);
	}
}


// sets some settings on start
void c2t_hccs_init() {
	// allow buy from NPCs
	set_property('_saved_autoSatisfyWithNPCs', get_property('autoSatisfyWithNPCs'));
	set_property('autoSatisfyWithNPCs', 'true');
	// allow buy from coinmasters (hermit)
	set_property('_saved_autoSatisfyWithCoinmasters', get_property('autoSatisfyWithCoinmasters'));
	set_property('autoSatisfyWithCoinmasters', 'true');
	//just to cover my butt if/when I turn recovery off in a previous session
	set_property('hpAutoRecovery', '0.6');
	
	visit_url('council.php');// Initialize council.
	
	//kinda need to use this script's ccs when doing manual interventions as well, which is why the original is not being saved and restored
	//set_property('_saved_customCombatScript',get_property('customCombatScript'));
	cli_execute('ccs c2t_hccs');
}

// resets some settings on exit
void c2t_hccs_exit() {
	set_property('autoSatisfyWithNPCs', get_property('_saved_autoSatisfyWithNPCs'));
	set_property('autoSatisfyWithCoinmasters', get_property('_saved_autoSatisfyWithCoinmasters'));
	//set_property('customCombatScript',get_property('_saved_customCombatScript'));
	set_property('hpAutoRecovery', '0.6');
	//don't want CS moods running during manual intervention or when fully finished
	cli_execute('mood apathetic');
}

boolean c2t_hccs_pre_coil() {
	//make sure to vote and comb for grain of sand first
	if (item_amount($item[&quot;I Voted!&quot; sticker]) == 0)
		abort("Need to vote!");
	if (item_amount($item[grain of sand]) == 0) {
		if (get_property('_freeBeachWalksUsed').to_int() < 5)
			abort("Comb the beach up to "+(5-get_property('_freeBeachWalksUsed').to_int())+" more times");
		else
			print("Warning: number of free-free combs exhausted with no grain of sand to show for it","blue");
	}

	// Clanmate fortunes (BAFH/CheeseFax)
	if (get_property('_clanFortuneConsultUses').to_int() < 3) {
		cli_execute('/whitelist bonus adventures from hell');
		while (get_property('_clanFortuneConsultUses').to_int() < 3) {
			cli_execute('fortune cheesefax');
			cli_execute('wait 5');
		}
	}
	if (get_property('_photocopyUsed') == 'false' && item_amount($item[photocopied monster]) == 0) {
		//print("THIS IS WHAT YOU'RE LOOKING FOR","blue");
		//set_property('faxbots','1');
		//cli_execute('faxbot factory worker');
		//faxbot($monster[1789], "CheeseFax");

		//since the above does not work, and neither do chatbot scripts:
		chat_private('cheesefax','fax factory worker');
		wait(15);//10 has failed multiple times
		cli_execute('fax get');
		if (!get_property('photocopyMonster').contains_text("factory worker")) {
			//cli_execute('fax send'); //probably don't do this, especially not with a loop as faxbot may be offline
			abort("wrong fax monster");
		}
	}
		
	use_skill(1,$skill[Spirit of Peppermint]);
	
	// should switch to just fish hatchet when get more stat buffs
	//if (my_primestat() == $stat[muscle]) {
	//	retrieve_item(1, $item[fish hatchet]);
	//}
	//else if (my_primestat() == $stat[mysticality]) {
	if (!get_property('_floundryItemCreated').to_boolean())
		if (!retrieve_item(1, $item[fish hatchet]))
			abort('failed to get a fish hatchet');
		/*if (!retrieve_item(1, $item[fish hatchet])) {
			retrieve_item(1, $item[codpiece]);
			try_use(1, $item[codpiece]);
			try_use(8, $item[bubblin' crude]);
			autosell(1, $item[oil cap]);
		}*/
	//}

	c2t_haveUse($item[astral six-pack]);

	//pantagramming
	c2t_hccs_pantagramming();

	//knock-off hero cape thing
	cli_execute('c2t_capeme '+my_primestat());

	//ebony epee from lathe
	if (item_amount($item[ebony epee]) == 0) {
		if (item_amount($item[SpinMaster&trade; Lathe]) > 0)
			visit_url('shop.php?whichshop=lathe');
		retrieve_item(1,$item[ebony epee]);
	}
	
	//retreive_item(1, $item[FantasyRealm Warrior's Helm]);
	if (item_amount($item[FantasyRealm G. E. M.]) == 0) {
		visit_url('place.php?whichplace=realm_fantasy&action=fr_initcenter');
		if (my_primestat() == $stat[muscle])
			run_choice(1);//1280,1 warrior; 1280,2 mage
		else if (my_primestat() == $stat[mysticality])
			run_choice(2);
		else if (my_primestat() == $stat[moxie])
			run_choice(3);//a guess
	}

	if (get_property('boomBoxSong') != 'Total Eclipse of Your Meat')
		cli_execute('boombox meat');

	// upgrade saber for familiar weight
	visit_url('main.php?action=may4');
	run_choice(4);
	
	// vote stuff
	
	// comb 5 random spots for drops
	// might have to pick spots to comb
	// int _freeBeachWalksUsed < 5

	// Sell pork gems
	visit_url('tutorial.php?action=toot');
	c2t_haveUse($item[letter from King Ralph XI]);
	c2t_haveUse($item[pork elf goodies sack]);
	autosell(5, $item[baconstone]);
	autosell(5, $item[porquoise]);
	autosell(5, $item[hamethyst]);

	// Buy toy accordion
	if (my_class() != $class[accordion thief]);
		retrieve_item(1, $item[toy accordion]);
	
	// equip mp stuff
	maximize("mp,-equip kramco,-equip i voted",false);

	// should have enough MP for this much; just being lazy here for now
	if (have_effect($effect[The Magical Mojomuscular Melody]) == 0)
		if (!use_skill(1,$skill[The Magical Mojomuscular Melody]))
			abort('mojomus fail');
	if (get_property('_candySummons').to_int() == 0)
		if (!use_skill(1,$skill[Summon Crimbo Candy]))
			abort('crimbo candy fail');
	if (available_amount($item[perfect ice cube]) == 0)
		if (!use_skill(1,$skill[Perfect Freeze]))
			abort('perfect freeze fail');
	
	if (available_amount($item[lime]) == 0) {
		if (my_mp() < 50) {
			//cli_execute('rest free'); <-- DANGEROUS
			if (get_property('timesRested').to_int() < total_free_rests())
				visit_url('place.php?whichplace=campaway&action=campaway_tentclick');
		}
		if (!use_skill(1,$skill[Prevent Scurvy and Sobriety]))
			abort('couldn\'t get rum and limes');
		cli_execute('breakfast'); //bool breakfastCompleted
	}
		
	// pre-coil pizza to get imitation whetstone for INFE pizza latter
	if (my_fullness() == 0/* && available_amount($item[imitation whetstone]) == 0*/) {
		// get imitation crab
		use_familiar($familiar[imitation crab]);
				
		// make pizza
		if (item_amount($item[diabolic pizza]) == 0) {
			int count = 3 - item_amount($item[cog and sprocket assembly]);
			retrieve_item(count,$item[cog]);
			retrieve_item(count,$item[sprocket]);
			retrieve_item(count,$item[spring]);
			create(count,$item[cog and sprocket assembly]);
			
			if (available_amount($item[blood-faced volleyball]) == 0) {
				hermit(1,$item[volleyball]);
				
				if (have_effect($effect[Bloody Hand]) == 0) {
					hermit(1, $item[seal tooth]);
					c2t_getEffect($effect[Bloody Hand],$item[seal tooth]);
				}
				use(1,$item[volleyball]);
			}
						
			eat_pizza(
				$item[cog and sprocket assembly],
				$item[cog and sprocket assembly],
				$item[cog and sprocket assembly],
				$item[blood-faced volleyball]
				);	
		}
		else
			eat(1,$item[diabolic pizza]);
		use_familiar($familiar[Hovering Sombrero]);
	}
	
	// need to fetch and drink some booze pre-coil. using semi-rare via pillkeeper in sleazy back alley
	/* going to be using borrowed time, so no longer need
	if (my_turncount() == 0) {
		cli_execute('pillkeeper semirare');
		if (get_property('semirareCounter').to_int() > 0) //does not work?
			abort('Semirare should be now. Something went wrong.');
		cli_execute('mood apathetic');
		cli_execute('counters nowarn Fortune Cookie');
		//maybe recover before this?
		adv1($location[The Sleazy Back Alley], -1, '');	  
	}
	
	// drinking
	if (my_inebriety() == 0 && available_amount($item[distilled fortified wine]) >= 2) {
		if (have_effect($effect[Ode to Booze]) < 2) {
			if (my_mp() < 50) { //this block is assuming my setup w/ getaway camp
				cli_execute('breakfast');
				
				//cli_execute('rest free'); //<-- DANGEROUS
				if (get_property('timesRested') < total_free_rests())
					visit_url('place.php?whichplace=campaway&action=campaway_tentclick');
			}
			if (!use_skill(1,$skill[The Ode to Booze]))
				abort("couldn't cast ode to booze");
		}
		drink(2,$item[distilled fortified wine]);
	}
	*/

	// borrowed time
	if (get_property('tomeSummons').to_int() == 0 && available_amount($item[borrowed time]) == 0)
		cli_execute('acquire borrowed time');
		//retrieve_item(1,$item['borrowed time']);
	if (!get_property('_borrowedTimeUsed').to_boolean())
		use(1,$item[borrowed time]);

	// box of familiar jacks
	// going to get camel equipment straight away
	if (/*my_primestat() != $stat[moxie]*/true) {
		if (available_amount($item[dromedary drinking helmet]) == 0 && get_property('tomeSummons').to_int() == 1 && available_amount($item[box of familiar jacks]) == 0)
			cli_execute('acquire box of familiar jacks');
			//retrieve_item(1,$item['box of familiar jacks']);
		if (available_amount($item[dromedary drinking helmet]) == 0 && available_amount($item[box of familiar jacks]) == 1) {
			use_familiar($familiar[Melodramedary]);
			use(1,$item[box of familiar jacks]);
		}
	}
	else if (get_property('tomeSummons').to_int() == 1)
		cli_execute('acquire cold-filtered water');//just to make sure to match tome counter; using it later anyway
	
	// beach access
	if (available_amount($item[bitchin' meatcar]) == 0) {
		retrieve_item(1,$item[cog]);
		retrieve_item(1,$item[sprocket]);
		retrieve_item(1,$item[spring]);
		retrieve_item(1,$item[empty meat tank]);
		retrieve_item(1,$item[sweet rims]);
		retrieve_item(1,$item[tires]);
		create(1,$item[bitchin' meatcar]);
	}

	// tune moon sign
	if (get_property('moonTuned') == 'false') {
		// Unequip spoon.
		cli_execute('unequip hewn moon-rune spoon');
		
		// Get some CSAs for later pizzas (CER & HGh)
		int count;
		if (my_primestat() == $stat[muscle]) //CER & HGh
			count = 3 - available_amount($item[cog and sprocket assembly]);
		else //CER & DIF or CER & KNI
			count = 2 - available_amount($item[cog and sprocket assembly]);
		retrieve_item(count,$item[cog]);
		retrieve_item(count,$item[sprocket]);
		retrieve_item(count,$item[spring]);
		create(count, $item[cog and sprocket assembly]);
		
		int gogogo = 0;
		switch (my_primestat()) {
			case $stat[muscle]:
				gogogo = 7;
				retrieve_item(1, $item[empty meat tank]);
				//if (available_amount($item[gnollish autoplunger]) == 0)
				//	create(1,$item[gnollish autoplunger]);
				break;
			case $stat[mysticality]:
				gogogo = 8;
				retrieve_item(2, $item[empty meat tank]);
				break;
			case $stat[moxie]:
				gogogo = 9;//a guess
				retrieve_item(1, $item[empty meat tank]);
				break;
			default:
				abort('something broke with moon sign changing');
		}
		visit_url('inv_use.php?whichitem=10254&doit=96&whichsign='+gogogo);

		/*
		if (my_primestat() == $stat[muscle]) {
			//HGh pizza //too expensive
			//if (available_amount($item[gnollish autoplunger]) == 0)
			//	create(1,$item[gnollish autoplunger]);
			//INFE pizza
			retrieve_item(1, $item[empty meat tank]);
			// Actually tune the moon. //7 = wombat/mus 8 = blender/mys
			visit_url('inv_use.php?whichitem=10254&doit=96&whichsign=7');
		}
		else if (my_primestat() == $stat[mysticality]) {
			//DIF pizza and INFE pizza
			retrieve_item(2, $item[empty meat tank]);
			// Actually tune the moon. //7 = wombat/mus 8 = blender/mys
			visit_url('inv_use.php?whichitem=10254&doit=96&whichsign=8');
		}*/
		
	}

	while (c2t_hccs_wandererFight());
	
	// get love potion before moving ahead, then dump if bad
	c2t_hccs_love_potion(false,true);
	
	return true;
}

// get experience buffs prior to using items that give exp
boolean c2t_hccs_buff_exp() {
	print('Getting experience buffs');
	// boost mus exp
	if (have_effect($effect[That's Just Cloud-Talk, Man]) == 0)
		visit_url('place.php?whichplace=campaway&action=campaway_sky');
	if (have_effect($effect[That's Just Cloud-Talk, Man]) == 0)
		abort('Getaway camp buff failure');

	
	// shower exp buff
	if (!get_property('_aprilShower').to_boolean())
		cli_execute('shower '+my_primestat());
	
	if (my_primestat() == $stat[muscle]) {
		use_familiar($familiar[Exotic Parrot]);//an attempt to get its familiar equipment to maybe test
		if (my_fullness() == 3 && have_effect($effect[HGH-charged]) == 0) {
			if (available_amount($item[diabolic pizza]) == 0) {
				if (available_amount($item[hot buttered roll]) == 0)
					retrieve_item(1,$item[hot buttered roll]);
				pizza_effect(
					$effect[HGH-charged],
					c2t_priority($item[hot buttered roll],$item[Hollandaise helmet],$item[helmet turtle]),
					c2t_priority($item[gnollish autoplunger],$item[green seashell],$item[grain of sand]),
					c2t_priority($item[blood-faced volleyball],$item[cog and sprocket assembly]),
					$item[cog and sprocket assembly]
				);
			}
			else
				eat(1,$item[diabolic pizza]);
		}
		
		// mus exp synthesis; allowing this to be able to fail maybe
		if (have_effect($effect[Synthesis: Movement]) == 0) {
			if (!sweet_synthesis($effect[Synthesis: Movement])) { //works or no?
				print('Note: Synthesis: Movement failed. Going to fight a hobelf and try again.');
				if (!have_equipped($item[Fourth of May Cosplay saber]))
					equip($item[Fourth of May Cosplay saber]);
				c2t_setChoice(1387,3);//saber yr
				if (!c2t_hccs_wishFight($monster[hobelf]))
					abort('Failed to fight hobelf');
				run_turn();
				c2t_setChoice(1387,0);
				if (!sweet_synthesis($effect[Synthesis: Movement]))
					abort('Somehow failed to synthesize even after fighting hobelf');
			}
		}
		
		if (numeric_modifier('muscle experience percent') < 89.999) {
			abort('Insufficient +exp%');
			return false;
		}
	}
	else if (my_primestat() == $stat[mysticality]) {
		use_familiar($familiar[imitation crab]);
		
		retrieve_item(1, $item[meat stack]);
		retrieve_item(1, $item[full meat tank]);
		if (my_fullness() == 3 && have_effect($effect[Different Way of Seeing Things]) == 0) {
			if (available_amount($item[diabolic pizza]) == 0) {
				pizza_effect(
					$effect[Different Way of Seeing Things],
					$item[dry noodles],
					$item[imitation whetstone],
					$item[full meat tank],
					$item[cog and sprocket assembly]
				);
			}
			else
				eat(1,$item[diabolic pizza]);
		}
		
		// mys exp synthesis; allowing this to be able to fail maybe
		if (have_effect($effect[Synthesis: Learning]) == 0) {
			if (!sweet_synthesis($effect[Synthesis: Learning])) { //works or no?
				print('Note: Synthesis: Learning failed. Going to fight a hobelf and try again.');
				if (!have_equipped($item[Fourth of May Cosplay saber]))
					equip($item[Fourth of May Cosplay saber]);
				c2t_setChoice(1387,3);//saber yr
				if (!c2t_hccs_wishFight($monster[hobelf]))
					abort('Failed to fight hobelf');
				run_turn();
				c2t_setChoice(1387,0);
				if (!sweet_synthesis($effect[Synthesis: Learning]))
					abort('Somehow failed to synthesize even after fighting hobelf');
			}
		}
		
		//face
		ensure_effect($effect[Inscrutable Gaze]);

		if (numeric_modifier('mysticality experience percent') < 99.999) {
			abort('Insufficient +exp%');
			return false;
		}
	}
	else if (my_primestat() == $stat[moxie]) {
		//going for KNIg for 200% moxie
		use_familiar($familiar[imitation crab]);

		// 7 adventures, 12 turns of effect
		if (my_fullness() == 3 && have_effect($effect[Knightlife]) == 0) {
			if (item_amount($item[ketchup]) == 0)
				cli_execute('acquire ketchup');
			if (available_amount($item[diabolic pizza]) == 0) {
				pizza_effect(
					$effect[Knightlife],
					$item[ketchup],
					$item[Newbiesport&trade; tent],
					$item[imitation whetstone],
					$item[cog and sprocket assembly]
				);
			}
			else
				eat(1,$item[diabolic pizza]);
		}

		// mox exp synthesis; allowing this to be able to fail maybe
		// if don't have the right candies, drop hardcore
		if (have_effect($effect[Synthesis: Style]) == 0)
			if (item_amount($item[Crimbo candied pecan]) == 0 || item_amount($item[Crimbo fudge]) == 0) {
				print("Didn't get the right candies for buffs, so dropping hardcore.","blue");
				c2t_dropHardcore();
				if (item_amount($item[Crimbo candied pecan]) == 0)
					cli_execute('pull crimbo candied pecan');
				if (item_amount($item[Crimbo fudge]) == 0)
					cli_execute('pull crimbo fudge');
			}
			if (!sweet_synthesis($effect[Synthesis: Style])) //works or no?
				//probably automate drop to softcore at this point and just pull needed candy
				print('Note: Synthesis: Style failed');

		if (numeric_modifier('moxie experience percent') < 89.999) {
			abort('Insufficient +exp%');
			return false;
		}
		//return false;//want to check state at this point
	}

	return true;
}

// should handle leveling up and eventually call free fights
boolean c2t_hccs_levelup() {
	if (my_level() < 7)
		if (c2t_hccs_buff_exp())
			c2t_haveUse($item[a ten-percent bonus]);
	if (my_level() < 7)
		abort('initial leveling broke');

	// using MCD as a flag, what could possibly go wrong?
	// figure out something less error-prone before ever making public
	if (current_mcd() != 10) {
		c2t_hccs_all_the_buffs();

		//feel excitement //putting it here because using a chat macro for it
		//chat_macro('/cast feel excitement');
	}
	
	return true;
}

// initialise limited-use, non-mood buffs for leveling
boolean c2t_hccs_all_the_buffs() {
	print('Getting pre-fight buffs','blue');
	// equip mp stuff
	maximize("mp,-equip kramco",false);
	
	if (have_effect($effect[One Very Clear Eye]) == 0) {
		//if (c2t_is_vote_fight_now())
		if (c2t_hccs_semirare_item())
			c2t_getEffect($effect[One Very Clear Eye],$item[cyclops eyedrops]);
	}

	//emotion chip stat buff
	c2t_getEffect($effect[Feeling Excited],$skill[Feel Excitement]);
	//if (have_effect($effect[Feeling Excited]) == 0 && get_property('_feelExcitementUsed').to_int() < $skill[Feel Excitement].dailylimit)
	//	use_skill(1,$skill[Feel Excitement]);
	
	c2t_getEffect($effect[The Magical Mojomuscular Melody],$skill[The Magical Mojomuscular Melody]);
	
	// daycare stat gain
	if (get_property('_daycareGymScavenges').to_int() == 0) {
		visit_url('place.php?whichplace=town_wrong&action=townwrong_boxingdaycare');
		run_choice(3);//1334,3 boxing daycare lobby->boxing daycare
		run_choice(2);//1336,2 scavenge
		if (get_property('_daycareRecruits').to_int() == 0)
			run_choice(1);//1336,1 recruit int _daycareRecruits
	}
	
	
	// getaway camp buff //probably causes infinite loop without getaway camp
	if (get_property('_campAwaySmileBuffs').to_int() == 0)
		visit_url('place.php?whichplace=campaway&action=campaway_sky');
	
	//monorail
	if (get_property('_lyleFavored') == 'false')
		ensure_effect($effect[Favored by Lyle]);
	
	ensure_effect($effect[Hulkien]); //pillkeeper stats
	ensure_effect($effect[Fidoxene]);//pillkeeper familiar
	
	ensure_effect($effect[You Learned Something Maybe!]); //beach exp
	ensure_effect($effect[Do I Know You From Somewhere?]);//beach fam wt
	if (my_primestat() == $stat[moxie])
		ensure_effect($effect[Pomp & Circumsands]);//beach moxie

	// Cast Ode and drink bee's knees
	// going to skip this for non-moxie to use clip art's buff of same strength
	if (my_primestat() == $stat[moxie] && have_effect($effect[On the Trolley]) == 0 && my_inebriety() == 0) {
		c2t_assert(my_meat() >= 500,"Need 500 meat for speakeasy booze");
		c2t_getEffect($effect[Ode to Booze],$skill[The Ode to Booze],5);
		//drink(1,$item[Bee's Knees]);//doesn't work
		cli_execute('drink 1 Bee\'s Knees');
		//probably don't need to drink the perfect drink; have to double-check all inebriety checks before removing
		//drink(1,$item[perfect dark and stormy]);
		//cli_execute('drink perfect dark and stormy');
	}
	//just in case
	if (have_effect($effect[Ode to Booze]) > 0)
		cli_execute('shrug ode to booze');
	
	//fortune buff item
	if (get_property('_clanFortuneBuffUsed') == 'false')
		ensure_effect($effect[There's No N In Love]);

	//cast triple size
	c2t_hccs_tripleSize();
	
	//boxing daycare, synthesis, and bastille
	if (my_primestat() == $stat[muscle]) {
		//try cli_execute('mummery mus');
		if (have_effect($effect[Muddled]) == 0)
			cli_execute('daycare mus');
		if (have_effect($effect[Synthesis: Strong]) == 0) {
			if (available_amount($item[Crimbo candied pecan]) > 0)
				retrieve_item(1, $item[jaba&ntilde;ero-flavored chewing gum]);
			else if (available_amount($item[Crimbo peppermint bark]) > 0)
				retrieve_item(1, $item[tamarind-flavored chewing gum]);
			sweet_synthesis($effect[Synthesis: Strong]);
		}
		if (get_property('_bastilleGames').to_int() == 0)
			cli_execute('bastille muscle');
	}
	else if (my_primestat() == $stat[mysticality]) {
		//try cli_execute('mummery mys');
		if (have_effect($effect[Uncucumbered]) == 0)
			cli_execute('daycare mys');
		if (have_effect($effect[Synthesis: Smart]) == 0) {
			if (available_amount($item[Crimbo peppermint bark]) > 0)
				retrieve_item(1, $item[lime-and-chile-flavored chewing gum]);
			else if (available_amount($item[Crimbo fudge]) > 0)
				retrieve_item(1, $item[tamarind-flavored chewing gum]);
			sweet_synthesis($effect[Synthesis: Smart]);
		}
		if (get_property('_bastilleGames').to_int() == 0)
			cli_execute('bastille myst brutalist');
	}
	else if (my_primestat() == $stat[moxie]) {
		if (have_effect($effect[Ten out of Ten]) == 0)
			cli_execute('daycare mox');
		if (have_effect($effect[Synthesis: Cool]) == 0) {
			if (available_amount($item[Crimbo peppermint bark]) > 0)
				retrieve_item(1,$item[pickle-flavored chewing gum]);
			else if (available_amount($item[Crimbo fudge]) > 0)
				retrieve_item(1,$item[lime-and-chile-flavored chewing gum]);
			else if (available_amount($item[Crimbo candied pecan]) > 0)
				retrieve_item(1,$item[tamarind-flavored chewing gum]);
			sweet_synthesis($effect[Synthesis: Cool]);
		}
		if (get_property('_bastilleGames').to_int() == 0)
			cli_execute('bastille moxie brutalist');
	}

	// Check G-9, then genie effect Experimental Effect G-9/New and Improved
	if (my_primestat() != $stat[moxie]) {// going to wish for an evil olive to saber YR for moxie
		if ((my_primestat() == $stat[muscle] &&
			(have_effect($effect[Synthesis: Strong]) == 0 || have_effect($effect[Synthesis: Movement]) == 0)) ||
			(my_primestat() == $stat[mysticality] && 
			(have_effect($effect[Synthesis: Smart]) == 0 || have_effect($effect[Synthesis: Learning]) == 0))
			) {
			//TODO handler to map/saber angry pinata if that would solve the issue (does for muscle + a certain crimbo candy)
			//or wish/saber hobelf

			//not going to wish for g9 anymore
			abort("Synthesize didn't work properly");

			/*
			print("Wishing for stat boost","blue");
			if (have_effect($effect[Experimental Effect G-9]) == 0 && have_effect($effect[New and Improved]) == 0) {
				effect g9 = $effect[Experimental Effect G-9];
				if (g9.numeric_modifier('muscle percent') < 0.001) {
					// Not cached. This should trick Mafia into caching the G-9 value for the day.
					visit_url('desc_effect.php?whicheffect=' + g9.descid);
					if (g9.numeric_modifier('muscle percent') < 0.001)
						abort('Check G9');
				}
				//if (my_primestat() == $stat[muscle]) {
					if (g9.numeric_modifier('muscle percent') > 200)
						wish_effect(g9);
					else
						wish_effect($effect[New and Improved]);
				//}
			}
			*/
		}
		else if (have_effect($effect[Purity of Spirit]) == 0) {
			print("Saving wish for disquiet riot, but using last tome for stat boost","blue");
			retrieve_item(1,$item[cold-filtered water]);
			use(1,$item[cold-filtered water]);
		}
	}
	//no longer using bee's knees for stat boost on non-moxie, but still need same strength buff?
	else if (have_effect($effect[Purity of Spirit]) == 0) {
		//technically should have the item already, so just making sure
		retrieve_item(1,$item[cold-filtered water]);
		use(1,$item[cold-filtered water]);
		use(item_amount($item[rhinestone]),$item[rhinestone]);
	}


	use_familiar($familiar[hovering sombrero]);
	
	cli_execute('telescope high');
	cli_execute('mcd 10');

	return true;
}

// get semirare from limerick dungeon
boolean c2t_hccs_semirare_item() {
	if (available_amount($item[cyclops eyedrops]) == 0 && have_effect($effect[One Very Clear Eye]) == 0) {
		if (get_property('_freePillKeeperUsed') == 'false')//my_spleen_use() == 0)
			cli_execute('pillkeeper semirare');
		else
			abort('free pillkeeper already used?');
		//recover hp
		if (my_hp() < (0.5 * my_maxhp()))
			cli_execute('hottub');
		cli_execute('mood apathetic');
		cli_execute('counters nowarn Fortune Cookie');
		adv1($location[The Limerick Dungeon], -1, '');
	}
	return true;
}

boolean c2t_hccs_love_potion(boolean useit) {
	return c2t_hccs_love_potion(useit,false);
}

boolean c2t_hccs_love_potion(boolean useit,boolean dumpit) {
	item love_potion = $item[Love Potion #0];
	effect love_effect = $effect[Tainted Love Potion];
	
	if (have_effect(love_effect) == 0) {
		if (available_amount(love_potion) == 0) {
			if (my_mp() < 50) { //this block is assuming my setup
				cli_execute('breakfast');						
				if (get_property('timesRested').to_int() < total_free_rests())
					visit_url('place.php?whichplace=campaway&action=campaway_tentclick');
				else
					abort('Ran out of free rests. Recover mp another way.');
			}
			use_skill(1,$skill[Love Mixology]);
		}
		visit_url('desc_effect.php?whicheffect='+love_effect.descid);
		
		if ((my_primestat() == $stat[muscle] && 
				(love_effect.numeric_modifier('mysticality').to_int() <= -50
				|| love_effect.numeric_modifier('muscle').to_int() <= 10
				|| love_effect.numeric_modifier('moxie').to_int() <= -50
				|| love_effect.numeric_modifier('maximum hp percent').to_int() <= -50))
			|| (my_primestat() == $stat[mysticality] &&
				(love_effect.numeric_modifier('mysticality').to_int() <= 10
				|| love_effect.numeric_modifier('muscle').to_int() <= -50
				|| love_effect.numeric_modifier('moxie').to_int() <= -50
				|| love_effect.numeric_modifier('maximum hp percent').to_int() <= -50))
			|| (my_primestat() == $stat[moxie] &&
				(love_effect.numeric_modifier('mysticality').to_int() <= -50
				|| love_effect.numeric_modifier('muscle').to_int() <= -50
				|| love_effect.numeric_modifier('moxie').to_int() <= 10
				|| love_effect.numeric_modifier('maximum hp percent').to_int() <= -50))) {
			if (dumpit) {
				use(1,love_potion);
				return true;
			}
			else {
				print('not using trash love potion','blue');
				return false;
			}
		}
		else if (useit) {
			use(1, love_potion);
			return true;
		}
		else {
			print('love potion should be good; holding onto it','blue');
			return false;
		}
	}
	//abort('error handling love potion');
	return false;
}

boolean c2t_hccs_pre_item() {
	//shrug off an AT buff
	cli_execute("shrug ur-kel");

	//get latte ingredient from fluffy bunny and cloake item buff
	if (have_effect($effect[Bat-Adjacent Form]) == 0 || !get_property('latteUnlocks').contains_text('carrot')) {
		maximize(my_primestat()+",equip latte,equip doc bag,equip vampyric cloake",false);
		while (have_effect($effect[Bat-Adjacent Form]) == 0 || !get_property('latteUnlocks').contains_text('carrot'))
			adv1($location[The Dire Warren],-1,"");
	}
	if (!get_property('latteModifier').contains_text('Item Drop') && get_property('_latteBanishUsed') == 'true')
		cli_execute('latte refill cinnamon carrot vanilla');

	ensure_effect($effect[Fat Leon's Phat Loot Lyric]);
	ensure_effect($effect[Singer's Faithful Ocelot]);
	ensure_effect($effect[The Spirit of Taking]);

	// might move back to levelup part
	if (have_effect($effect[Certainty]) == 0) {
		if (my_fullness() != 6)
			abort('fullness not where it should be for CER pizza');
		if (available_amount($item[electronics kit]) == 0)
			abort('missing electronics kit for CER pizza');

		pizza_effect(
			$effect[Certainty],
			$item[cog and sprocket assembly],
			$item[electronics kit],
			$item[razor-sharp can lid],
			c2t_priority($item[Middle of the Road&trade; brand whiskey],$item[PB&J with the crusts cut off],$item[surprisingly capacious handbag])
		);
	}
	
	// might move back to level up part
	if (have_effect($effect[Infernal Thirst]) == 0) {
		if (my_fullness() != 9)
			abort('fullness not where it should be for INFE pizza');
		// random chance to get cracker until able to reliably replace electronics kit in recipe
		use_familiar($familiar[Exotic Parrot]);
		
		if (available_amount($item[full meat tank]) == 0) {
			if (available_amount($item[empty meat tank]) > 0)
				create(1,$item[full meat tank]);
			else
				abort('could not make full meat tank for INFE pizza');
		}

		if (item_amount($item[eldritch effluvium]) == 0 && item_amount($item[eaves droppers]) == 0 && (item_amount($item[cracker]) == 0 || item_amount($item[electronics kit]) == 0))
			retrieve_item(1,$item[eyedrops of the ermine]);

		pizza_effect(
			$effect[Infernal Thirst],
			$item[imitation whetstone],
			c2t_priority($item[neverending wallet chain], $item[Newbiesport&trade; tent]),
			$item[full meat tank],
			c2t_priority($item[eldritch effluvium],$item[eaves droppers],$item[eyedrops of the ermine],$item[electronics kit])
		);
	}
	
	//spice ghost
	if (my_class() == $class[pastamancer]) {
		if (my_thrall() != $thrall[Spice Ghost]) {
			if (my_mp() < 250)
				cli_execute('eat magical sausage');
			use_skill($skill[Bind Spice Ghost]);
		}
	}
	else {
		if (my_mp() < 250)
			cli_execute('eat magical sausage');
		ensure_effect($effect[Spice Haze]);
	}

	//AT-only buff
	if (my_class() == $class[accordion thief])
		ensure_song($effect[The Ballad of Richie Thingfinder]);

	ensure_effect($effect[Nearly All-Natural]);//bag of grain
	ensure_effect($effect[Steely-Eyed Squint]);
	
	/* doesn't work
	use_familiar($familiar[Leprechaun]);
	if (!get_property('_mummeryUses').contains_text('4'))
		cli_execute('mummery item');
	*/
	
	maximize('item,2 booze drop,-equip broken champagne bottle,-equip surprisingly capacious handbag,-equip red-hot sausage fork', false);
	
	//TODO put formula here to turn this into turns instead of whatever this is
	//if (numeric_modifier('Booze Drop') < 335 || numeric_modifier('Item Drop') < 725)
	//still need to fight things in next test... maybe?
	if ((60 - floor(numeric_modifier('Booze Drop') / 15 + 0.001) - floor(numeric_modifier('Item Drop') / 30 + 0.001)) > 1)
		c2t_getEffect($effect[Feeling Lost],$skill[Feel Lost]);
	if (PRINT_MODTRACE)
		cli_execute("modtrace item drop;modtrace booze drop");
	if ((60 - floor(numeric_modifier('Booze Drop') / 15 + 0.001) - floor(numeric_modifier('Item Drop') / 30 + 0.001)) > 1)
		return false;

	return true;
}

boolean c2t_hccs_pre_hot_res() {
	//this has been moved to the familiar test to take advantage of meteor shower there
	/*
	if (item_amount($item[lava-proof pants]) == 0 && item_amount($item[photocopied monster]) > 0 && get_property('photocopyMonster').contains_text('factory worker')) {
		equip($item[Fourth of May Cosplay Saber]);
		c2t_setChoice(1387,3);//saber yr
		use(1,$item[photocopied monster]);
		run_turn();
		c2t_setChoice(1387,0);
	}
	*/

	//this is mostly for weapon test, but also combos for cloake hot res
	//should last 15 turns, which is enough to get through hot(1), NC(9), and weapon(1) tests to also affect the spell test
	if (have_effect($effect[Do You Crush What I Crush?]) == 0 && have_familiar($familiar[Ghost of Crimbo Carols]) && (get_property('_snokebombUsed').to_int() < 3 || !get_property('_latteBanishUsed').to_boolean())) {
		equip($item[Vampyric Cloake]);
		equip($item[Latte Lovers member's mug]);
		if (my_mp() < 30)
			cli_execute('rest free');
		use_familiar($familiar[Ghost of Crimbo Carols]);
		adv1($location[The Dire Warren],-1,"");
	}

	//attempting to skip this
	/*
	if (have_effect($effect[Feeling No Pain]) == 0) {
		if (my_meat() < 500) {
			abort('Not enough meat. Please autosell stuff.');
		}
		if (my_inebriety() > 11) {
			abort('Too drunk. Something is wrong.');
		}
		ensure_ode(2);
		//drink(1,$item[Ish Kabibble]);//doesn't work
		cli_execute('drink 1 Ish Kabibble');
	}
	*/

	if (have_effect($effect[Synthesis: Hot]) == 0) {
		retrieve_item(2, $item[jaba&ntilde;ero-flavored chewing gum]);
		sweet_synthesis($item[jaba&ntilde;ero-flavored chewing gum], $item[jaba&ntilde;ero-flavored chewing gum]);
	}

	use_familiar($familiar[Exotic Parrot]);
	//try_equip($item[cracker]);//should be taken care of by maximizer

	ensure_effect($effect[Blood Bond]);
	ensure_effect($effect[Leash of Linguini]);
	ensure_effect($effect[Empathy]);

	// Pool buff. This will fall through to fam weight. //fam weight is before hot now
	//ensure_effect($effect[Billiards Belligerence]);

	if (have_effect($effect[Rainbowolin]) == 0)
		cli_execute('pillkeeper elemental');

	//potion making not needed with retro cape
	/*
	retrieve_item(1, $item[tenderizing hammer]);
	cli_execute('smash * ratty knitted cap');
	cli_execute('smash * red-hot sausage fork');

	if (available_amount($item[hot powder]) > 0)
		ensure_effect($effect[Flame-Retardant Trousers]);

	if (available_amount($item[sleaze nuggets]) > 0 || available_amount($item[lotion of sleaziness]) > 0)
		ensure_potion_effect($effect[Sleazy Hands], $item[lotion of sleaziness]);
	*/

	//retro cape
	cli_execute('c2t_capeme resistance');

	if (get_property('_genieWishesUsed').to_int() < 3 || available_amount($item[pocket wish]) > 0)
		cli_execute("genie effect "+$effect[Fireproof Lips]);

	ensure_effect($effect[Elemental Saucesphere]);
	ensure_effect($effect[Astral Shell]);

	// Beach comb buff.
	ensure_effect($effect[Hot-Headed]);

	//emotion chip
	c2t_getEffect($effect[Feeling Peaceful],$skill[Feel Peaceful]);
	
	// Use pocket maze
	ensure_effect($effect[Amazing]);
	
	//familiar weight
	ensure_effect($effect[Blood Bond]);
	ensure_effect($effect[Leash of Linguini]);
	ensure_effect($effect[Empathy]);

	//magenta seashell
	//if (available_amount($item[magenta seashell]) > 0)
	//	ensure_effect($effect[Too Cool for (Fish) School]);

	maximize('100hot res, familiar weight', false);
	// need to run this twice because familiar weight thresholds interfere with it?
	maximize('100hot res, familiar weight', false);

	if (PRINT_MODTRACE)
		cli_execute("modtrace hot resistance");
	//test takes 1 turn
	if (numeric_modifier('hot resistance') < 59) {
		//TODO probably check for buff before recommending
		print("Maybe drink Ish Kabibble?","red");
		return false;
	}

	return true;
}

boolean c2t_hccs_pre_familiar() {
	//sabering factory worker for meteor shower
	if (item_amount($item[lava-proof pants]) == 0 && item_amount($item[photocopied monster]) > 0 && get_property('photocopyMonster').contains_text('factory worker')) {
		equip($item[Fourth of May Cosplay Saber]);
		c2t_setChoice(1387,3);//saber yr
		use(1,$item[photocopied monster]);
		run_turn();
		c2t_setChoice(1387,0);
	}
	//make retro cape a stat cape again after hot test
	cli_execute('c2t_capeme '+my_primestat());
	
	// These should have fallen through all the way from leveling.
	//ensure_effect($effect[Fidoxene]);
	//ensure_effect($effect[Do I Know You From Somewhere?]);

	// Pool buff. // should be carried over from pre-hot res
	ensure_effect($effect[Billiards Belligerence]);

	if (my_hp() < 30) use_skill(1, $skill[Cannelloni Cocoon]);
	ensure_effect($effect[Blood Bond]);
	ensure_effect($effect[Leash of Linguini]);
	ensure_effect($effect[Empathy]);

	//AT-only buff
	if (my_class() == $class[accordion thief])
		ensure_song($effect[Chorale of Companionship]);

	use_familiar($familiar[Exotic Parrot]);
	maximize('familiar weight', false);

	if (PRINT_MODTRACE)
		cli_execute("modtrace familiar weight");
	if (numeric_modifier('familiar weight') < 275) {//70
		//TODO check for hot socks effect; should have been drank elsewhere?
		print("Maybe drink Hot Socks?","red");
		return false;
	}
	
	return true;
}


boolean c2t_hccs_pre_noncombat() {
	if (my_hp() < 30) use_skill(1, $skill[Cannelloni Cocoon]);
	ensure_effect($effect[Blood Bond]);
	ensure_effect($effect[Leash of Linguini]);
	ensure_effect($effect[Empathy]);

	// Pool buff. Should fall through to weapon damage.
	//not going to use this here, as it doesn't do to the noncombat rate in the moment anyway
	//ensure_effect($effect[Billiards Belligerence]);

	equip($slot[acc3], $item[Powerful Glove]);

	ensure_effect($effect[The Sonata of Sneakiness]);
	ensure_effect($effect[Smooth Movements]);
	ensure_effect($effect[Invisible Avatar]);

	ensure_effect($effect[Silent Running]);

	if (have_effect($effect[Silence of the God Lobster]) == 0) {
		cli_execute('mood apathetic');
		use_familiar($familiar[god lobster]);
		equip($item[God Lobster's Ring]);
		
		string shirt;
		if (get_property('garbageShirtCharge') > 0)
			shirt = ",equip garbage shirt";
		maximize(my_primestat() + ",-familiar" + shirt,false);
		//abort('Need to fight globster and get its buff to continue');
		//fight and get buff
		c2t_setChoice(1310,2); //get buff
		visit_url('main.php?fightgodlobster=1');
		run_turn();
		if (choice_follows_fight())
			run_choice(2);
		c2t_setChoice(1310,0); //unset
		/*
		run_turn();
		if (!handling_choice()) abort("No choice?");
		if (last_choice() == 1310 && count(available_choice_options()) > 0)
			run_choice(2);//get buff
		*/
	}

	//emotion chip feel lonely
	if (have_effect($effect[Feeling Lonely]) == 0 && get_property('_feelLonelyUsed').to_int() < $skill[Feel Lonely].dailylimit)
		use_skill(1,$skill[Feel Lonely]);
	
	// Rewards // use these after globster fight, just in case of losing
	ensure_effect($effect[Throwing Some Shade]);
	ensure_effect($effect[A Rose by Any Other Material]);


	//can get disquiet riot if didn't need to use it for g9 or other stat booster to save 8 turns (12 max)
	//TODO find better wish; disquiet riot now only saves 1-2 turns with emotion chip and change in routing
	/*
	if (have_effect($effect[Disquiet Riot]) == 0 && item_amount($item[pocket wish]) > 1)
		wish_effect($effect[Disquiet Riot]);
	*/

	use_familiar($familiar[Disgeist]);

	maximize('-100combat, familiar weight', false);

	if (PRINT_MODTRACE)
		cli_execute("modtrace combat rate");
	if (round(numeric_modifier('combat rate')) > -40) {//37
		//chat_macro('/cast feel lonely');
		return false;
	}

	return true;
}

boolean c2t_hccs_pre_weapon() {
	if (get_property('camelSpit').to_int() != 100 && /*my_primestat() != $stat[moxie] &&*/ have_effect($effect[Spit Upon]) == 0)
		abort('Camel spit only at '+get_property('camelSpit')+'%.');

	//cast triple size
	c2t_hccs_tripleSize();

	if (my_mp() < 500 && my_mp() != my_maxmp())
		cli_execute('eat mag saus');

	// moved to hot res test
	/*if (have_effect($effect[Do You Crush What I Crush?]) == 0 && have_familiar($familiar[Ghost of Crimbo Carols]) && (get_property('_snokebombUsed').to_int() < 3 || !get_property('_latteBanishUsed').to_boolean())) {
		equip($item[Latte Lovers member's mug]);
		if (my_mp() < 30)
			cli_execute('rest free');
		use_familiar($familiar[Ghost of Crimbo Carols]);
		adv1($location[The Dire Warren],-1,"");
	}*/

	if (have_effect($effect[In a Lather]) == 0) {
		if (my_inebriety() > inebriety_limit() - 2)
			abort('Something went wrong. We are too drunk.');
		c2t_assert(my_meat() >= 500,"Need 500 meat for speakeasy booze");
		ensure_ode(2);
		cli_execute('drink Sockdollager');
	}

	if (available_amount($item[twinkly nuggets]) > 0)
		ensure_effect($effect[Twinkly Weapon]);

	ensure_effect($effect[Carol of the Bulls]);
	ensure_effect($effect[Rage of the Reindeer]);
	ensure_effect($effect[Frenzied, Bloody]);
	ensure_effect($effect[Scowl of the Auk]);
	ensure_effect($effect[Tenacity of the Snapper]);
	
	//don't have these skills yet. maybe should add check for all skill uses to make universal?
	if (have_skill($skill[Song of the North]))
		ensure_effect($effect[Song of the North]);
	if (have_skill($skill[Jackasses' Symphony of Destruction]))
		ensure_song($effect[Jackasses' Symphony of Destruction]);

	if (available_amount($item[vial of hamethyst juice]) > 0)
		ensure_effect($effect[Ham-Fisted]);

	// Hatter buff
	if (available_amount($item[&quot;DRINK ME&quot; potion]) > 0) {
		retrieve_item(1, $item[goofily-plumed helmet]);
		ensure_effect($effect[Weapon of Mass Destruction]);
	}

	// Beach Comb
	ensure_effect($effect[Lack of Body-Building]);

	// apparently doesn't work
	//if (get_property('boomBoxSong') != 'These Fists Were Made for Punchin\'')
	//	cli_execute('boombox damage');

	// Boombox potion - did we get one?
	if (available_amount($item[Punching Potion]) > 0)
		ensure_effect($effect[Feeling Punchy]);

	// Pool buff. Should have fallen through from noncom
	ensure_effect($effect[Billiards Belligerence]);

	// Corrupted marrow 
	// meteor shower gets used here, though probably not needed if TT or PM
	if (have_effect($effect[cowrruption]) == 0 && item_amount($item[corrupted marrow]) == 0) {
		if (get_property('camelSpit').to_int() == 100 || my_primestat() == $stat[moxie]) {
			cli_execute('mood apathetic');

			//only 2 things needed for combat:
			equip($item[Fourth of May Cosplay Saber]);
			use_familiar($familiar[Melodramedary]);

			if (!c2t_hccs_wishFight($monster[ungulith]))
				abort('failed to fight ungulith');
			//c2t_setChoice(1387,3);//saber yr
			//cli_execute('genie monster ungulith');
			//run_choice(-1);
			//run_turn();familiar_weight($familiar[pocket professor])+weight_adjustment()
		}
		//else if (my_primestat() == $stat[moxie]) //moxie doesn't use camel
		//	cli_execute('genie effect cowrruption');
		else
			abort("Camel spit is only at "+get_property('camelSpit'));
	}
	c2t_setChoice(1387,0);

	//if (my_primestat() == $stat[muscle])
		ensure_effect($effect[Cowrruption]);
	//else
	//	print('Cowrruption skipped','orange');

	if (have_effect($effect[Engorged Weapon]) == 0) {
		retrieve_item(1,$item[Meleegra&trade; pills]);
		use(1,$item[Meleegra&trade; pills]);
	}
	
	//tainted seal's blood
	if (available_amount($item[tainted seal's blood]) > 0)
		ensure_effect($effect[Corruption of Wretched Wally]);

	if (have_effect($effect[Outer Wolf&trade;]) == 0 && my_fullness() == 12) {
		//use(available_amount($item[van key]), $item[van key]);
		if (available_amount($item[ointment of the occult]) == 0) {
			// Should have a second grapefruit from Scurvy.
			// but maybe not enough reagents
			create(1, $item[ointment of the occult]);
		}
		if (available_amount($item[unremarkable duffel bag]) == 0) {
			// get useless powder.
			retrieve_item(1, $item[cool whip]);
			cli_execute('smash 1 cool whip');
		}
		
		// OU pizza requires funky logic, as it's not so simple as to make a priority list for last 2
		// TODO maybe make something to figure out last 2 ingredients so not having to copy/paste so much
		// this is currently an incomplete, lazy implementation; and will fail rarely
		if (available_amount($item[Middle of the Road&trade; brand whiskey]) > 1) {
			pizza_effect(
				$effect[Outer Wolf&trade;],
				c2t_priority($item[ointment of the occult],$item[out-of-tune biwa]),
				c2t_priority($item[unremarkable duffel bag],$item[useless powder]),
				$item[Middle of the Road&trade; brand whiskey],
				$item[Middle of the Road&trade; brand whiskey]
				//c2t_priority($item[Middle of the Road&trade; brand whiskey],$item[surprisingly capacious handbag],$item[PB&J with the crusts cut off])
			);
		}
		else if (available_amount($item[Middle of the Road&trade; brand whiskey]) > 0) {
			pizza_effect(
				$effect[Outer Wolf&trade;],
				c2t_priority($item[ointment of the occult],$item[out-of-tune biwa]),
				c2t_priority($item[unremarkable duffel bag],$item[useless powder]),
				$item[Middle of the Road&trade; brand whiskey],
				c2t_priority($item[surprisingly capacious handbag],$item[PB&J with the crusts cut off])
			);
		}
	}
	if (have_effect($effect[Outer Wolf&trade;]) == 0)
		abort('OU pizza failed');

	//wish_effect($effect[Pyramid Power]);
	//wish_effect($effect[Wasabi With You]);

	/* have meteor lore now
	if (my_class() != $class[pastamancer] || my_class() != $class[turtle tamer]) {
		if (have_effect($effect[Rictus of Yeg]) == 0) {
			cli_execute("cargo item yeg's motel toothbrush");
			use(1,$item[Yeg's Motel Toothbrush]);
		}
	}
	*/

	int testlimit = 19;
	if (my_class() == $class[turtle tamer]) {
		// turtle tamer saves ~1 turn with this part, and 4 from voting
		testlimit = 14;
		
		if (have_effect($effect[Boon of She-Who-Was]) == 0) {
			ensure_effect($effect[Blessing of She-Who-Was]);
			ensure_effect($effect[Boon of She-Who-Was]);
		}
		ensure_effect($effect[Blessing of the War Snapper]);
	}
	else
		ensure_effect($effect[Disdain of the War Snapper]);
	
	ensure_effect($effect[Bow-Legged Swagger]);
	
	maximize('weapon damage', false);


	// this is here for pvp purposes // should last for next
	//ensure_effect($effect[We're All Made of Starfish]);
	
	if (PRINT_MODTRACE)
		cli_execute("modtrace weapon damage");
	if ((60 - floor(numeric_modifier('weapon damage') / 25 + 0.001) - floor(numeric_modifier('weapon damage percent') / 25 + 0.001)) > 1) {//testlimit
		//TODO add some check for this effect and whether the resource exists to be used
		print("make/drink Bordeaux Marteaux maybe?","orange");
		return false;
	}
	return true;
}

boolean c2t_hccs_pre_spell() {
	if (my_mp() < 500 && my_mp() != my_maxmp())
		cli_execute('eat mag saus');

	// This will use an adventure.
	// if spit upon == 1, simmering will just waste a turn to do essentially nothing.
	// probably good idea to add check for similar effects to not just waste a turn
	if (have_effect($effect[Spit Upon]) != 1 && have_effect($effect[Do You Crush What I Crush?]) != 1)
		ensure_effect($effect[Simmering]);

	while (c2t_hccs_wandererFight()); //check for after using a turn to cast Simmering

	//don't have this skill yet. Maybe should add check for all skill uses to make universal?
	if (have_skill($skill[Song of Sauce]))
		ensure_effect($effect[Song of Sauce]);
	if (have_skill($skill[Jackasses' Symphony of Destruction]))
		ensure_effect($effect[Jackasses' Symphony of Destruction]);
	
	ensure_effect($effect[Carol of the Hells]);

	// Pool buff
	ensure_effect($effect[Mental A-cue-ity]);

	// Beach Comb
	ensure_effect($effect[We're All Made of Starfish]);

	use_skill(1, $skill[Spirit of Peppermint]);
	
	// face
	ensure_effect($effect[Arched Eyebrow of the Archmage]);

	if (available_amount($item[flask of baconstone juice]) > 0)
		ensure_effect($effect[Baconstoned]);

	retrieve_item(2, $item[obsidian nutcracker]);

	//AT-only buff
	if (my_class() == $class[accordion thief])
		ensure_song($effect[Elron's Explosive Etude]);

	// cargo pocket
	if (have_effect($effect[Sigils of Yeg]) == 0 && !get_property('_cargoPocketEmptied').to_boolean()) {
		if (!get_property('_cargoPocketEmptied').to_boolean())
			cli_execute("cargo item Yeg's Motel hand soap");
		use(1,$item[Yeg's Motel hand soap]);
	}

	// meteor lore // moxie can't do this, as it wastes a saber on evil olive -- moxie should be able to do this now with nostalgia earlier?
	if (have_effect($effect[Meteor Showered]) == 0 && get_property('_saberForceUses').to_int() < 5) {
		maximize(my_primestat()+",equip fourth may",false);
		c2t_setChoice(1387,3);//saber yr
		adv1($location[Thugnderdome],-1,"");//everything is saberable and no crazy NCs
		c2t_setChoice(1387,0);
	}

	if (have_effect($effect[Visions of the Deep Dark Deeps]) == 0) {
		ensure_effect($effect[Elemental Saucesphere]);
		ensure_effect($effect[Astral Shell]);
		maximize("1000spooky res,hp,mp",false);
		if (my_hp() < 800)
			use_skill(1,$skill[Cannelloni Cocoon]);
		ensure_effect($effect[Visions of the Deep Dark Deeps]);
	}

	maximize('spell damage', false);

	if (PRINT_MODTRACE)
		cli_execute("modtrace spell damage");
	//need to add check. ~46 turn currently
	if ((60 - floor(numeric_modifier('spell damage') / 25 + 0.001) - floor(numeric_modifier('spell damage percent') / 25 + 0.001)) > 1)//46
		return false;

	return true;
}





// stat tests are super lazy for now
// TODO need to figure out a way to not overdo buffs, as some buffers may be needed for pizzas
boolean c2t_hccs_pre_hp() {
	if (my_maxhp() - my_buffedstat($stat[muscle]) - 3 >= 1770)
		return true;
	maximize('hp',false);
	if (my_maxhp() - my_buffedstat($stat[muscle]) - 3 >= 1770)
		return true;
	return false;
}

boolean c2t_hccs_pre_mus() {
	//TODO if pastamancer, add summon of mus thrall if need? currently using equaliser potion out of laziness
	if (my_buffedstat($stat[muscle]) - my_basestat($stat[muscle]) >= 1770)
		return true;
	maximize('mus', false);
	if (my_buffedstat($stat[muscle]) - my_basestat($stat[muscle]) >= 1770)
		return true;
	return false;
}

boolean c2t_hccs_pre_mys() {
	if (my_buffedstat($stat[mysticality]) - my_basestat($stat[mysticality]) >= 1770)
		return true;
	maximize('mys',false);
	if (my_buffedstat($stat[mysticality]) - my_basestat($stat[mysticality]) >= 1770)
		return true;
	return false;
}

boolean c2t_hccs_pre_mox() {
	//TODO if pastamancer, add summon of mox thrall if need? currently using equaliser potion out of laziness
	if (my_buffedstat($stat[moxie]) - my_basestat($stat[moxie]) >= 1770)
		return true;
	maximize('mox',false);
	if (my_buffedstat($stat[moxie]) - my_basestat($stat[moxie]) >= 1770)
		return true;
	return false;
}

void c2t_hccs_fights() {
	//TODO move familiar changes and maximizer calls inside of blocks
	// saber yellow ray stuff
	if (available_amount($item[tomato juice of powerful power]) == 0 && available_amount($item[tomato]) == 0 && have_effect($effect[Tomato Power]) == 0) {
		//don't need hound dog with map the monsters. going to keep for now as to not accidentally have crab as familiar. familiar doesn't really matter here anyway
		use_familiar($familiar[Jumpsuited Hound Dog]);
		//probably don't need this array of banish power with map the monsters
		maximize(my_primestat()+",equip garbage shirt,equip fourth may,equip latte,equip powerful glove,equip doc bag,equip vampyric cloake",false);
		cli_execute('mood apathetic');

		if (my_hp() < 0.5 * my_maxhp())
			cli_execute('rest free');
		
		// Fruits in skeleton store (Saber YR)
		if ((available_amount($item[ointment of the occult]) == 0 && available_amount($item[grapefruit]) == 0 && have_effect($effect[Mystically Oiled]) == 0)
				|| (available_amount($item[oil of expertise]) == 0 && available_amount($item[cherry]) == 0 && have_effect($effect[Expert Oiliness]) == 0)) { //todo: add mus pot
			if (get_property('questM23Meatsmith') == 'unstarted') {
				// Have to start meatsmith quest.
				visit_url('shop.php?whichshop=meatsmith&action=talk');
				run_choice(1);
			}
			if (!can_adv($location[The Skeleton Store], false))
				abort('Cannot open skeleton store!');
			adv1($location[The Skeleton Store], -1, '');
			if (!$location[The Skeleton Store].noncombat_queue.contains_text('Skeletons In Store'))
				abort('Something went wrong at skeleton store.');

			c2t_setChoice(1387,3);//saber yr
			c2t_cartographyHunt($location[The Skeleton Store], $monster[novelty tropical skeleton]);
			run_turn();
			run_choice(-1);//just in case
			c2t_setChoice(1387,0);
		}

		// Tomato in pantry (NOT Saber YR) -- RUNNING AWAY to use nostalgia later
		//TODO might be good to change subsequent fight to piranha plant or globster instead of tentacle, since tentacle boss is a thing
		if (available_amount($item[tomato juice of powerful power]) == 0
			&& available_amount($item[tomato]) == 0
			&& have_effect($effect[Tomato Power]) == 0
			&& !get_property('feelNostalgicMonster').contains_text($monster[possessed can of tomatoes].to_string())
			) {
			//thanks to map the monsters, dump extra latte banish on bunny to fish for latte ingredient
			if (!get_property('_latteBanishUsed').to_boolean())
				adv1($location[The Dire Warren],-1,"");

			//probably don't need the next 2 lines with the Map the Monsters skill
			//ensure_effect($effect[Musk of the Moose]);
			//ensure_effect($effect[Carlweather's Cantata of Confrontation]);
			//ensure_mp_tonic(50); // For Snokebomb.

			if (get_property('_latteDrinkUsed').to_boolean())
				cli_execute('latte refill cinnamon pumpkin vanilla');

			//c2t_setChoice(1387,3);//saber yr
			//should run from this
			c2t_cartographyHunt($location[The Haunted Pantry], $monster[possessed can of tomatoes]);
			run_turn();
			//run_choice(-1);//just in case
			//c2t_setChoice(1387,0);
		}
	}
	
	if (have_effect($effect[The Magical Mojomuscular Melody]) > 0)
		cli_execute('shrug mojomus');
	if (have_effect($effect[Carlweather's Cantata of Confrontation]) > 0)
		cli_execute('shrug cantata');
	if (have_effect($effect[Stevedave's Shanty of Superiority]) == 0)
		use_skill(1,$skill[Stevedave's Shanty of Superiority]);
	
	//sort out familiar
	if (my_class() == $class[seal clubber] || available_amount($item[dromedary drinking helmet]) > 0) {
		use_familiar($familiar[melodramedary]);
		if (available_amount($item[dromedary drinking helmet]) > 0) {
			equip($item[dromedary drinking helmet]);
			//prepend += "equip dromedary drinking helmet,";
		}
		else
			equip($item[astral pet sweater]);
	}
	else {
		use_familiar($familiar[hovering sombrero]);
		equip($item[astral pet sweater]);
	}
	familiar levelingFam = my_familiar();
	
	if (my_primestat() == $stat[muscle] && !get_property('_mummeryUses').contains_text('3'))
		cli_execute('mummery mus');
	else if (my_primestat() == $stat[mysticality] && !get_property('_mummeryUses').contains_text('5'))
		cli_execute('mummery mys');
	else if (my_primestat() == $stat[moxie] && !get_property('_mummeryUses').contains_text('7'))
		cli_execute('mummery mox');
	
	
	if (my_primestat() == $stat[muscle])
		cli_execute('mood hccs-mus');
	else if (my_primestat() == $stat[mysticality])
		cli_execute('mood hccs-mys');
	else if (my_primestat() == $stat[moxie])
		cli_execute('mood hccs-mox');

	//spice ghost
	if (my_class() == $class[pastamancer]) {
		if (my_thrall() != $thrall[Spice Ghost]) {
			if (my_mp() < 250)
				cli_execute('eat magical sausage');
			use_skill($skill[Bind Spice Ghost]);
		}
	}

	//turtle tamer blessing
	if (my_class() == $class[turtle tamer]) {
		if (have_effect($effect[Blessing of the War Snapper]) == 0 && have_effect($effect[Grand Blessing of the War Snapper]) == 0 && have_effect($effect[Glorious Blessing of the War Snapper]) == 0)
			use_skill($skill[Blessing of the War Snapper]);	
		if (have_effect($effect[Boon of the War Snapper]) == 0)
			use_skill(1,$skill[Spirit Boon]);
	}

	use_familiar(levelingFam);

	//summon tentacle
	if (have_skill($skill[Evoke Eldritch Horror]) && !get_property('_eldritchHorrorEvoked').to_boolean()) {
		//getting a tomato from this
		if (get_property('feelNostalgicMonster').contains_text($monster[possessed can of tomatoes].to_string())) {
			maximize(my_primestat()+",100exp,-familiar,-equip garbage shirt",false);
			if (my_mp() < 80)
				cli_execute('rest free');
			use_skill(1,$skill[Evoke Eldritch Horror]);
			run_combat();
		}
		else
			abort("Something broke with trying to feel nostalgic for tomatoes");
	}


	//get crimbo ghost buff from dudes at NEP
	if (have_effect($effect[Holiday Yoked]) == 0) {
		// declining quest
		// to add: accept if booze or food quest
		c2t_setChoice(1322,2);
		use_familiar($familiar[Ghost of Crimbo Carols]);
		maximize(my_primestat()+",equip latte,-equip i voted",false);
		adv1($location[The Neverending Party],-1,"");
		//first should have been the non-combat, so a second go:
		if (have_effect($effect[Holiday Yoked]) == 0)
			adv1($location[The Neverending Party],-1,"");
		c2t_assert(have_effect($effect[Holiday Yoked]) > 0,"Something broke trying to get Holiday Yoked");
	}

	use_familiar(levelingFam);

	// Your Mushroom Garden
	if (get_property('_mushroomGardenFights').to_int() == 0) {
		maximize(my_primestat()+",-familiar,equip garbage shirt",false);
		//cli_execute('mood execute');
		adv1($location[Your Mushroom Garden],-1,"");
	}
	if (!get_property('_mushroomGardenVisited').to_boolean()) {
		c2t_setChoice(1410,1);//fertilize
		adv1($location[Your Mushroom Garden],-1,"");
		run_turn();
		c2t_setChoice(1410,0);//unset choice
	}

	c2t_hccs_wandererFight();//hopefully doesn't do kramco

	// God Lobster
	if (get_property('_godLobsterFights').to_int() < 2) {
		use_familiar($familiar[god lobster]);
		maximize(my_primestat()+",equip garbage shirt",false);
		
		// fight and get equipment
		while (get_property('_godLobsterFights').to_int() < 2) {
			c2t_setChoice(1310,1);//get equipment
			if (my_hp() < 0.5 * my_maxhp())
				visit_url('clan_viplounge.php?where=hottub');

			item temp = c2t_priority($item[God Lobster's Ring],$item[God Lobster's Scepter],$item[astral pet sweater]);
			if (temp != $item[none])
				equip($slot[familiar],temp);

			//combat & choice
			visit_url('main.php?fightgodlobster=1');
			run_turn();
			if (choice_follows_fight())
				run_choice(-1);
			c2t_setChoice(1310,0);//unset
			/*
			run_turn();
			if (!handling_choice()) abort("No choice?");
			if (last_choice() == 1310 && count(available_choice_options()) > 0)
				run_choice(1);//get equipment
			*/
		}
	}

	// NEP 11 free sausage goblin fights
	if (c2t_sausageGoblinOdds() >= 0.9999 && get_property('_pocketProfessorLectures').to_int() < 9) {
		//kind of important to get meat here, so double checking
		if (get_property('boomBoxSong') != "Total Eclipse of Your Meat")
			cli_execute('boombox meat');

		use_familiar($familiar[Pocket Professor]);
		maximize(my_primestat()+",equip garbage shirt,equip kramco,100familiar weight",false);
		if (!get_property('_mummeryUses').contains_text('1'))
			cli_execute('mummery meat');

		if (my_hp() < 0.8 * my_maxhp())
			visit_url('clan_viplounge.php?where=hottub');
		if (get_property('_sausageFights').to_int() < 9)
			adv1($location[The Neverending Party],-1,"");
	}

	//potion buffs
	if (my_primestat() == $stat[muscle] && have_effect($effect[Tomato Power]) == 0) {
		c2t_getEffect($effect[Phorcefullness],$item[philter of phorce]);
		c2t_getEffect($effect[Stabilizing Oiliness],$item[oil of stability]);
		c2t_getEffect($effect[Tomato Power],$item[tomato juice of powerful power]);
	}
	else if (my_primestat() == $stat[mysticality] && have_effect($effect[Tomato Power]) == 0) {
		c2t_getEffect($effect[Mystically Oiled],$item[ointment of the occult]);
		c2t_getEffect($effect[Expert Oiliness],$item[oil of expertise]);
		c2t_getEffect($effect[Tomato Power],$item[tomato juice of powerful power]);
	}
	else if (my_primestat() == $stat[moxie] && have_effect($effect[Tomato Power]) == 0) {
		if (have_effect($effect[Slippery Oiliness]) == 0 && item_amount($item[jumbo olive]) == 0) {
			//only thing that needs be equipped
			equip($item[Fourth of May Cosplay saber]);
			//TODO evil olive - change to run away from and feel nostagic+envy+free kill another thing to save a saber use for spell test
			c2t_assert(c2t_hccs_wishFight($monster[Evil Olive]),"Failed to fight evil olive");
		}
		c2t_getEffect($effect[Superhuman Sarcasm],$item[serum of sarcasm]);
		c2t_getEffect($effect[Slippery Oiliness],$item[oil of slipperiness]);
		c2t_getEffect($effect[Tomato Power],$item[tomato juice of powerful power]);
	}

	c2t_assert(have_effect($effect[Tomato Power]) > 0,'It somehow missed again.');

	//drink astral pilsners; saving 1 for use in mime army shotglass post-run
	if (my_level() >= 11 && item_amount($item[astral pilsner]) == 6) {
		cli_execute('shrug Shanty of Superiority');
		if (my_mp() < 100)
			cli_execute('rest free');//probably bad
		use_skill(1,$skill[The Ode to Booze]);
		drink(5,$item[astral pilsner]);
		cli_execute('shrug Ode to Booze');
		use_skill(1,$skill[Stevedave's Shanty of Superiority]);
	}

	/* starting to have this bleed into the -combat test, so need to remove
	// possibility: do pvp fights to remove instead of not use at all?
	if (have_effect($effect[Mush-Maw]) == 0) {
		cli_execute('make mushroom tea');
		chew(1,$item[mushroom tea]);
	}*/


	// setup for NEP fights
	string prepend = my_primestat();
	//set familiar and maximize equipment
	if (/*my_primestat() != $stat[moxie]*/true) {//this is assuming moxie cannot use camel for now, otherwise would just check for fam equipment
		use_familiar($familiar[Melodramedary]);
		prepend += ",equip dromedary drinking helmet,";
	}
	else {
		use_familiar($familiar[hovering sombrero]);
		if (available_amount($item[astral pet sweater]) > 0)
			prepend += ",equip astral pet sweater,";
		else //maybe have everything not break if astral pet sweater not chosen
			prepend += ",";
	}

	//neverending party fights
	//probably have to change this to only use free fights once can cap combat test without boombox potion
	string append;
	while (get_property('_gingerbreadMobHitUsed') == 'false') { //no longer running non-free fights
	//while (item_amount($item[Punching Potion]) == 0 && get_property('_boomBoxFights').to_int() > 8) {
		// -- combat logic --
		//use doc bag kills first after free fights
		if (get_property('_neverendingPartyFreeTurns').to_int() == 10 && get_property('_chestXRayUsed').to_int() < 3)
			append = ",equip doc bag";
		else
			append = "";
		//swap song to fists when it's ready for next non-free fight
		if (get_property('_boomBoxFights').to_int() == 10) {
			if (get_property('boomBoxSong') != "These Fists Were Made for Punchin'")
				cli_execute('boombox fists');
		}
		//in case something changed the song previously
		else if (get_property('boomBoxSong') != "Total Eclipse of Your Meat")
			cli_execute('boombox meat');
		//equip better gear if found while fighting
		maximize(prepend+"equip garbage shirt,equip kramco"+append,false);

		// -- noncombat logic --
		//going for stat exp buff initially, then combats afterward
		if (my_primestat() == $stat[muscle] && have_effect($effect[Spiced Up]) == 0) {
			c2t_setChoice(1324,2);
			c2t_setChoice(1326,2);
		}
		else if (my_primestat() == $stat[mysticality] && have_effect($effect[Tomes of Opportunity]) == 0) {
			c2t_setChoice(1324,1);
			c2t_setChoice(1325,2);
		}
		else if (my_primestat() == $stat[moxie] && have_effect($effect[The Best Hair You've Ever Had]) == 0) {
			c2t_setChoice(1324,4);
			c2t_setChoice(1328,2);//need to verify
		}
		else if (get_property('choiceAdventure1324').to_int() != 5)
			c2t_setChoice(1324,5);

		//use runproof mascara ASAP if moxie for more stats
		if (my_primestat() == $stat[moxie] && have_effect($effect[Unrunnable Face]) == 0 && item_amount($item[runproof mascara]) > 0)
			use(1,$item[runproof mascara]);

		//turtle tamer turtle
		if (my_class() == $class[turtle tamer] && have_effect($effect[Gummi-Grin]) == 0 && item_amount($item[gummi turtle]) > 0)
			use(1,$item[gummi turtle]);

		//eat CER pizza ASAP
		if (have_effect($effect[Certainty]) == 0 && item_amount($item[electronics kit]) > 0 && item_amount($item[Middle of the Road&trade; brand whiskey]) > 0)
			pizza_effect(
				$effect[Certainty],
				$item[cog and sprocket assembly],
				$item[electronics kit],
				$item[razor-sharp can lid],
				$item[Middle of the Road&trade; brand whiskey]
			);

		//drink hot socks ASAP
		if (have_effect($effect[1701]) == 0 && my_meat() > 5000) {//1701 is the desired version of $effet[Hip to the Jive]
			if (my_mp() < 150)
				cli_execute('eat mag saus');
			cli_execute('shrug stevedave');
			c2t_getEffect($effect[Ode to Booze],$skill[The Ode to Booze],3);
			cli_execute('drink hot socks');
			cli_execute('shrug ode to booze');
			c2t_getEffect($effect[Stevedave's Shanty of Superiority],$skill[Stevedave's Shanty of Superiority]);
		}

		//make sure have some mp
		if (my_mp() < 50)
			cli_execute('eat magical sausage');

		adv1($location[The Neverending Party],-1,"");
	}

	//back to singing about meat
	if (get_property('boomBoxSong') != "Total Eclipse of Your Meat")
		cli_execute('boombox meat');

	//unset neverending party choices
	c2t_setChoice(1324,0);
	c2t_setChoice(1325,0);
	c2t_setChoice(1326,0);
	c2t_setChoice(1328,0);

	cli_execute('mood apathetic');
}


boolean c2t_hccs_wandererFight() {
	/* probably doesn't matter to do wanderer while feeling lost, unless an unlucky superlikely takes a turn
	if (have_effect($effect[Feeling Lost]) > 0) {//don't want to be doing wanderer whilst feeling lost
		print("Currently feeling lost, so skipping wanderer(s).","blue");
		return false;
	}
	*/
		
	string append;
	//try to do professor copies before doing extra kramco
	if (c2t_isVoterNow())
		append = ",equip i voted";
	else if (c2t_sausageGoblinOdds() > 0.9999 && (turns_played() == 0 || get_property('_pocketProfessorLectures').to_int() > 7))
		append = ",equip kramco";
	else
		return false;

	if (my_hp() < my_maxhp()/2 || my_mp() < 10) {
		cli_execute('breakfast;rest free');
	}
	print("Running wanderer fight","blue");
	cli_execute('outfit save backupcs');
	familiar nowFam = my_familiar();
	item nowEquip = equipped_item($slot[familiar]);
	if (/*my_primestat() != $stat[moxie]*/true) {
		use_familiar($familiar[melodramedary]);
		append += ",equip dromedary drinking helmet";
	}
	else {
		use_familiar($familiar[hovering sombrero]);
		if (available_amount($item[astral pet sweater]) > 0)
			append += ",equip astral pet sweater";
	}
	if (turns_played() == 0)
		append += ",-equip garbage shirt,exp";
	else
		append += ",equip garbage shirt";
	maximize(my_primestat()+append,false);
	adv1($location[The Neverending Party],-1,"");//this might break something if NEP quest not taken care of yet
	cli_execute('outfit backupcs');//fails if foldable was changed, usually because of wad of used tape changing into garbage shirt; shouldn't matter though, as maximizer is run before most actions
	use_familiar(nowFam);
	equip($slot[familiar],nowEquip);
	return true;
}


// will fail if haiku dungeon stuff spills outside of itself, so probably avoid that or make sure to do combats elsewhere just before a test
boolean c2t_hccs_test_done(int test) {
	print('Checking test '+test+'...');
	if (test == 30 && !get_property('kingLiberated').to_boolean() && get_property("csServicesPerformed").split_string(",").count() == 11)
		return false;//to do the 'test' and to set kingLiberated
	else if (get_property('kingLiberated').to_boolean())
		return true;
	return get_property('csServicesPerformed').contains_text(TEST_NAME[test]);
}

void c2t_hccs_do_test(int test) {
	if (!c2t_hccs_test_done(test)) {
		//c2t_setChoice(1089,test);//doesn't seem to work
		visit_url('council.php');
		visit_url('choice.php?pwd&whichchoice=1089&option='+test,true,true);
		//run_turn();
		//run_choice(-1);
		//c2t_setChoice(1089,0);
		if (!c2t_hccs_test_done(test))
			abort('Failed to do test '+test+'. Maybe out of turns?');
	} else
		print('Test '+test+' already completed.');
}

