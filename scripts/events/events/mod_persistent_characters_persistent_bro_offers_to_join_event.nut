this.mod_persistent_characters_persistent_bro_offers_to_join_event <- ::inherit("scripts/events/event", {
	m = {
		Bro = null,
		Demand = null,
		OriginalCompanyName = null,
		OriginalCompanyBanner = null,
		TextVariant = null
	},
	function create()
	{
		this.m.ID = "event.mod_persistent_characters_persistent_bro_offers_to_join";
		this.m.Title = "A familiar face"
		this.m.Cooldown = 30.0 * ::World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Banner = "",
			Options = [],
			function start( _event )
			{
				this.Characters.push(_event.m.Bro.getImagePath());
				this.Banner = "ui/banners/" + _event.m.OriginalCompanyBanner + "s.png";

				switch (_event.m.TextVariant)
				{
					case 1:
						this.Text = "[img]gfx/ui/events/event_26.png[/img]As your company makes camp for the night, a lone traveler approaches, his silhouette outlined against the dying light of the setting sun. As he steps closer, the firelight reveals a face weathered by time and battle, but one that sparks a distant recognition.%SPEECH_ON%%bro%?%SPEECH_OFF%The grizzled veteran grins and gestures toward the fire.%SPEECH_ON%Aye, it’s me, Captain. Or should I say, *a* captain. Heard there was a new band of sellswords on the rise, and lo and behold, here you are.%SPEECH_OFF%%randombrother% shifts uneasily.%SPEECH_ON%You know this old dog?%SPEECH_OFF%You nod.%SPEECH_ON%%bro% was with the %brocompanyname%. A fine company, one of the best I've known.%SPEECH_OFF%Chuckling, %bro% sits down on a nearby log.%SPEECH_ON%One of the best, eh? Now, that’s an interesting way to put it. We had our highs, we had our lows. Some campaigns were brilliant, others... well, let’s just say the less spoken of them, the better.%SPEECH_OFF%He smirks knowingly, as if sharing an inside joke with the gods themselves.%SPEECH_ON%But the thing is, we’re not marching these days. The %brocompanyname% is on hiatus. Some of the lads are nursing wounds, some are spending their spoils, and others just needed a break from this life. Not me, though. I live for the road, for the fight, for the next job. And since fate led me here, I figure I’ll throw my lot in with your crew—if you’ll have me.%SPEECH_OFF%%randombrother% crosses his arms.%SPEECH_ON%And what makes you think you’re worth the trouble, old man?%SPEECH_OFF%With a hearty laugh, %bro% spreads his arms.%SPEECH_ON%Fair question! I don’t just walk into a company for free. If I join, I need to know I’m not wasting my time. So, two options, Captain. Either your best man bests me in a fair duel—prove to me you’ve got someone worth following—or you pay me enough to make it worth my while. Your call.%SPEECH_OFF%The fire crackles as your men murmur among themselves, waiting for your decision."
						break;
					case 2:
						this.Text = "[img]gfx/ui/events/event_10.png[/img]The dirt road winds through a thick patch of forest, the air cool beneath the canopy of trees. Your company moves at an easy pace, enjoying the shade after a long march under the sun. Then, up ahead, a lone figure emerges from the undergrowth, stepping onto the road as if he had been waiting for you. Your men react instantly, hands drifting toward weapons, but you hold up a hand. You know that stance, that face.%SPEECH_ON%%bro%.%SPEECH_OFF%The veteran grins, brushing some dirt from his armor.%SPEECH_ON%Still got sharp eyes, I see. I was wondering if you’d spot me before someone put a crossbow bolt in my gut.%SPEECH_OFF%%randombrother% scowls.%SPEECH_ON%You’re lucky the captain recognized you first.%SPEECH_OFF%%bro% chuckles, shaking his head.%SPEECH_ON%Aye, well, I prefer luck over skill sometimes. And here I was, thinking I’d have to track you down. New faces, same stubborn bastard leading them. I should’ve guessed.%SPEECH_OFF%%randombrother2% folds his arms.%SPEECH_ON%So what’s your story? And why aren’t you with the %brocompanyname%?%SPEECH_OFF%%bro% exhales, stretching his shoulders before nodding toward the road ahead.%SPEECH_ON%We’re taking a break. Some of the boys got rich, some got tired, and others just wanted to drink themselves into oblivion for a while. Not me, though. Never did like sitting still. And wouldn’t you know it, my feet led me right to you.%SPEECH_OFF%He taps the hilt of his weapon.%SPEECH_ON%I could use some work, and you could use a man who knows how to fight. But I don’t just sign on with anyone. So let’s make it fair—either your best fighter beats me in a duel, or you pay me enough to make it worth my while. What do you say, Captain?%SPEECH_OFF%The decision hangs heavy in the air, as the trees rustle and your men murmur amongst themselves, watching you weigh the offer.";
						break;
					case 3:
						this.Text = "[img]gfx/ui/events/event_58.png[/img]The wind sweeps across the vast grasslands, bending the tall grass like waves on the ocean. Your company moves in a loose formation, the open sky stretching endlessly above. The distant storm clouds on the horizon threaten rain, but for now, the march is calm. Until you see the lone figure walking toward you. %randombrother% shades his eyes.%SPEECH_ON%Someone’s coming.%SPEECH_OFF%At first, he’s just another traveler on the road. But as he draws closer, something about his gait, his posture, the easy way he carries himself, tickles at your memory. Then he grins.%SPEECH_ON%Fancy meeting you out here, Captain.%SPEECH_OFF%You stop in your tracks.%SPEECH_ON%%bro%?%SPEECH_OFF%%bro% nods, stopping a few paces away.%SPEECH_ON%The very same. What are the odds, eh?%SPEECH_OFF%%randombrother2% eyes him warily.%SPEECH_ON%You know this guy?%SPEECH_OFF%Smirking, you nod.%SPEECH_ON%You could say that. We’ve fought side by side before.%SPEECH_OFF%%bro% lets out a short laugh.%SPEECH_ON%Aye, and I recall some campaigns going better than others. But let’s not dwell on the past. Fresh faces, same game. You know, the %brocompanyname% isn’t on the road these days. Some of the boys have coin to burn, others just got tired of marching. Me, though? I still get restless.%SPEECH_OFF%His hand rests casually on the pommel of his weapon.%SPEECH_ON%So here’s the deal, Captain. I’ll join you, but I’m not signing up just for the sake of it. Either you prove you’ve got fighters worth their salt who can best me in a duel, or you pay me enough to make it worth my while. What’s it going to be?%SPEECH_OFF%The wind howls over the grass as your company waits in tense silence and your men look to you for a decision.";
						break;
					case 4:
						this.Text = "[img]gfx/ui/events/event_137.png[/img]The river runs swift and steady beside your company’s path, its waters catching the golden hues of the afternoon sun. A stone bridge comes into view up ahead, and standing upon it is a lone figure, watching your approach with arms crossed. Your men slow their pace, sensing something unusual. As you draw closer, the man on the bridge smirks.%SPEECH_ON%I had a feeling I’d run into you sooner or later, Captain.%SPEECH_OFF%You squint, then recognition strikes.%SPEECH_ON%%bro%.%SPEECH_OFF%%bro% nods, stepping forward to meet you halfway across the bridge.%SPEECH_ON%Looks like you’ve got a new company to lead. Can’t say I’m surprised.%SPEECH_OFF%%randombrother% rests a hand on his weapon’s hilt.%SPEECH_ON%Who’s this, then?%SPEECH_OFF%You answer without hesitation.%SPEECH_ON%Someone I used to march with. A damn fine fighter, if nothing else.%SPEECH_OFF%%bro% chuckles.%SPEECH_ON%I’ll take that as high praise. The %brocompanyname% isn’t marching these days. Some of the lads needed a break, some got rich, some got dead. Me? I need something to keep my sword hand busy.%SPEECH_OFF%He glances at the men behind you.%SPEECH_ON%And you’ve got something I want: a challenge. Either I join you after besting your best fighter, or you pay me to make it worth my time. What do you say, Captain?%SPEECH_OFF%The company watches, waiting for the captain’s judgment. The river flows under the bridge, its powerful current echoing the weight of the decision before you.";
						break;
				}

				if (::World.Assets.getMoney() >= _event.m.Demand)
				{
					this.Options.push({
						Text = "I\'ll pay you " + _event.m.Demand + " crowns up front and " + _event.m.Bro.getDailyCost() + " daily",
						function getResult( _event )
						{
							return "AcceptWithCoin";
						}
					});

					this.Options.push({
						Text = "We don\'t need you",
						function getResult( _event )
						{
							return "Reject";
						}
					});
				}
				else
				{
					this.Options.push({
						Text = "We cannot afford you (" + _event.m.Demand + " crowns up front and " + _event.m.Bro.getDailyCost() + " daily)",
						function getResult( _event )
						{
							return "Reject";
						}
					});
				}
			}
		});
		this.m.Screens.push({
			ID = "AcceptWithCoin",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Banner = "",
			Options = [
				{
					Text = "Welcome to the %companyname%!",
					function getResult( _event )
					{
						::World.getPlayerRoster().add(_event.m.Bro);
						::World.getTemporaryRoster().clear();
						_event.m.Bro.onHired();
						::ModPersistentCharacters.addBlockedBro(_event.m.Bro.ModPersistentCharacters_getUID());
						return 0;
					}
				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bro.getImagePath());
				this.Banner = "ui/banners/" + _event.m.OriginalCompanyBanner + "s.png";

				switch (_event.m.TextVariant)
				{
					case 1:
						this.Text = "[img]gfx/ui/events/event_65.png[/img]The grizzled veteran smiles, his eyes gleaming with approval as he clasps his hands behind his back.%SPEECH_ON%Well, that’s the spirit, Captain! I can respect a man who knows what he wants. You’ve got yourself a deal.%SPEECH_OFF%He steps forward, offering a firm handshake.%SPEECH_ON%I’ll be worth every crown, I assure you.%SPEECH_OFF%With a satisfied nod, the veteran settles into camp, already making himself at home by the fire. The men watch curiously as he pulls out a flask and pours himself a drink. Soon, his deep voice rises in a tale from his past, one that captivates the attention of your soldiers. It seems this old dog has more stories than you can count—and likely more than a few lessons to offer along the way.";
						break;
					case 2:
						this.Text = "[img]gfx/ui/events/event_65.png[/img]The veteran chuckles, a grin spreading across his face as he takes the offered crowns.%SPEECH_ON%A wise choice, Captain. Seems like we understand each other well enough.%SPEECH_OFF%He slips the crowns into a pouch, then pats it with a satisfied nod.%SPEECH_ON%Don’t worry, I’ll make sure you get your money’s worth. This old dog still has plenty of fight left in him.%SPEECH_OFF%With that, he draws closer to the company, his easy gait suggesting he’s already adjusting to his new role. The men watch, some with skepticism, others with curiosity, but all of them are waiting to see if the grizzled veteran will live up to his words. The atmosphere lightens as he joins the ranks, his presence adding an air of confidence to your growing company.";
						break;
					case 3:
						this.Text = "[img]gfx/ui/events/event_65.png[/img]The veteran nods, a satisfied grin crossing his face as he takes the offered crowns.%SPEECH_ON%Fair enough, Captain. I’ll make sure to earn every last crown you’ve thrown my way.%SPEECH_OFF%He pockets the gold, then looks over your men, sizing them up with a sharp gaze.%SPEECH_ON%We’ll see what they’re made of. I’ll take my place in the ranks and show them how it’s done.%SPEECH_OFF%He steps to the side, walking alongside your men as they continue their march. The air around him seems to shift; his presence both grounding and intimidating. As the company moves forward, there’s a quiet sense of anticipation, as if the men are eager to see the veteran in action. His reputation is yet to be proven, but one thing is clear—he intends to live up to it.";
						break;
					case 4:
						this.Text = "[img]gfx/ui/events/event_65.png[/img]The veteran gives a satisfied grunt as he accepts the hefty payment, his fingers brushing the crowns with a smile.%SPEECH_ON%Ah, now we’re talking. You won’t regret this, Captain. Not a single crown.%SPEECH_OFF%He slides the crowns into his pouch, giving a contented sigh.%SPEECH_ON%I’ll do what I do best. Let’s see what these lads are made of.%SPEECH_OFF%With that, he strides confidently across the bridge and joins your ranks, settling into place as though he’s always belonged there. Your men give him an inquisitive glance, sizing up the new arrival. A few quiet murmurs pass between them, but the veteran’s calm confidence settles the nerves of the group. He’s here, and the march continues, now with a man who’s seen more battles than most of your company put together.";
						break;
				}
			}
		});
		this.m.Screens.push({
			ID = "Reject",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Banner = "",
			Options = [
				{
					Text = "Farewell",
					function getResult( _event )
					{
						::World.getTemporaryRoster().clear();
						return 0;
					}
				}
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Bro.getImagePath());
				this.Banner = "ui/banners/" + _event.m.OriginalCompanyBanner + "s.png";

				switch (_event.m.TextVariant)
				{
					case 1:
						this.Text = "[img]gfx/ui/events/event_64.png[/img]The grizzled veteran lets out a deep sigh, his eyes hardening as he looks you over.%SPEECH_ON%Guess I misjudged the situation.%SPEECH_OFF%He shakes his head, a wry smile tugging at the corners of his lips.%SPEECH_ON%No worries, Captain. It’s your company, your rules. I’ll find my way elsewhere.%SPEECH_OFF%He turns away, but as he walks off into the fading light, you catch the slightest slump of his shoulders. The men around the fire exchange uneasy glances, the flickering flames casting long shadows on their faces. %randombrother% shifts uncomfortably in his seat.%SPEECH_ON%You sure about this, Captain? That man’s seen more battles than most of us combined.%SPEECH_OFF%You nod, but the decision still weighs on you and you find yourself lost in thought. %randombrother2% eyes the veteran's retreating figure and tries to rationalize your decision.%SPEECH_ON%Sometimes it's about more than just strength. We’ve got enough on our plate already. He could’ve been trouble, Captain. You’re right to keep the peace. But damn, he had a lot of experience.%SPEECH_OFF%The fire crackles in the silence that follows. The man is gone now, but the choice lingers in the air like smoke. As the embers die down, you wonder if you’ve made the right call or if you've let a valuable asset slip away. This night feels colder than the ones before.";
						break;
					case 2:
						this.Text = "[img]gfx/ui/events/event_64.png[/img]The veteran shakes his head, a look of annoyance flashing across his face.%SPEECH_ON%Fine. You won’t have to worry about me tagging along.%SPEECH_OFF%He mutters something under his breath as he turns on his heel and strides back into the underbrush, the sound of his boots muffled by the dense forest. The air seems to grow still, the tension hanging in the silence as you watch him disappear from view. %randombrother% looks at you, his face conflicted.%SPEECH_ON%Was that the right call? We could’ve used someone like that. It’s not every day someone like him just walks up and asks to join. We may regret turning him away.%SPEECH_OFF%You shake your head, trying to push aside the nagging doubt.%SPEECH_ON%We’ve got enough to worry about.%SPEECH_OFF%%randombrother2% eyes you, shifting his weight from one foot to the other, and when he speaks, he sounds rather unsure of himself.%SPEECH_ON%Well, at least we saved a few crowns, eh? More for us to drink with later.%SPEECH_OFF%An uncomfortable silence follows his words broken only by the rustle of the trees' leaves. You look back toward the path the veteran took, now empty. You know that the decision wasn’t an easy one, and maybe it wasn’t even the right one. But for now, your company marches forward, perhaps with a loss that’ll be felt later.";
						break;
					case 3:
						this.Text = "[img]gfx/ui/events/event_64.png[/img]The veteran’s face falls, disappointment clear in his eyes.%SPEECH_ON%Fair enough, Captain. Can’t say I didn’t try.%SPEECH_OFF%He stands still for a moment, taking in the silence before letting out a long sigh.%SPEECH_ON%Guess I’ll be off then. Take care, Captain. Keep your head down out here.%SPEECH_OFF%With that, he steps back and begins walking away, his boots kicking up dust as he disappears into the vast, open landscape. The wind picks up, carrying the sound of his footsteps away. The men stand quietly, the weight of the decision settling over them. %randombrother% looks out at the horizon, his arms folded across his chest.%SPEECH_ON%You think we did the right thing, Captain? We could’ve used that man’s experience.%SPEECH_OFF%You exhale slowly.%SPEECH_ON%There's more to running a mercenary company than just hiring veterans with experience.%SPEECH_OFF%%randombrother2% squints at the vanishing figure, his voice thoughtful.%SPEECH_ON%He might have been a good asset, but it’s your call, Captain. You’ve got to keep us tight and ready for what’s coming next. Maybe he’d just slow us down. Who knows? I trust you know what you're doing.%SPEECH_OFF%The wind sweeps across the grasslands, and for a moment, the decision feels weightier than ever. You can’t shake the feeling that you’ve let something valuable go, but you’ll have to make do.";
						break;
					case 4:
						this.Text = "[img]gfx/ui/events/event_64.png[/img]The veteran’s lets out a low grumble.%SPEECH_ON%Guess I was hoping for more than that, Captain.%SPEECH_OFF%He looks at you for a moment, his expression hard and unreadable. Then his eyes narrow before he turns and starts walking away without another word, his boots crunching against the gravel. The sound of his footsteps soon fades into the distance, the river’s steady flow once again filling the silence. %randombrother% looks to you, his gaze hard.%SPEECH_ON%You sure that was the best move, Captain? That man knew how to fight.%SPEECH_OFF%You nod slowly, trying to shake off the doubt.%SPEECH_ON%It’s not just about skill. We need focus right now. We don’t need his baggage.%SPEECH_OFF%You feel a brief pang of guilt but quickly dismiss it. It wasn’t the right time for old memories or familiar faces. You won't let this company be weighed down by ghosts from the past.%randombrother2% lets out a sigh, glancing at the veteran’s retreating figure.%SPEECH_ON%He had more experience than most of us combined. But it’s your call, Captain.%SPEECH_OFF%The river flows steadily beneath the bridge, and the air feels charged with the weight of the decision. You can’t shake the feeling that you’ve passed on something valuable. As the veteran disappears from view, you turn back to the company, the road ahead still uncertain.";
						break;
				}
			}
		});
	}

	function onUpdateScore()
	{
		local currentCampaignUID = ::ModPersistentCharacters.getCampaignUID();
		local currentBros = ::World.getPlayerRoster().getAll().filter(@(_, _b) _b.ModPersistentCharacters_getUID() != null && _b.ModPersistentCharacters_getCampaignUID() != currentCampaignUID);

		if (currentBros.len() >= 10)
			return;

		local hasValidCampaign = false;
		local renownThreshold = ::World.Assets.getBusinessReputation() / (::ModPersistentCharacters.Mod.ModSettings.getSetting("RequiredRenown").getValue() * 0.01);
		local dataManaager = ::ModPersistentCharacters.getDataManager();
		foreach (campaignData in dataManaager.getCampaigns())
		{
			if (campaignData.getBusinessReputation() > renownThreshold)
				continue;

			foreach (broUID in campaignData.getBroUIDs())
			{
				if (dataManaager.getBro(broUID).canSpawn())
				{
					this.m.Score = 100 - currentBros.len() * 10;
					return;
				}
			}
		}
	}

	function onPrepare()
	{
		local dataManaager = ::ModPersistentCharacters.getDataManager();
		local currentCampaignUID = ::ModPersistentCharacters.getCampaignUID();
		local renownThreshold = ::World.Assets.getBusinessReputation() / (::ModPersistentCharacters.Mod.ModSettings.getSetting("RequiredRenown").getValue() * 0.01);
		local campaignData = ::ModPersistentCharacters.getDataManager().getRandomCampaign(function( _c ) {
			if (_c.getUID() == currentCampaignUID || _c.getBusinessReputation() > renownThreshold || _c.validateRequiredMods() != null)
				return false;

			foreach (broUID in _c.getBroUIDs())
			{
				if (dataManaager.getBro(broUID).canSpawn())
				{
					return true;
				}
			}

			return false;
		});

		local blockedBros = ::ModPersistentCharacters.getBlockedBros();
		local broData = campaignData.getRandomBro(@(_b) blockedBros.find(_b.getUID()) == null);

		this.m.Bro = broData.createBro(::World.getTemporaryRoster());
		this.m.Bro.getBackground().adjustHiringCostBasedOnEquipment();

		this.m.Demand = this.m.Bro.getHiringCost();

		local weapon = this.m.Bro.getMainhandItem();
		if (weapon != null && weapon.getID().find("banner") != null)
		{
			this.m.Bro.getItems().unequip(weapon);
		}

		this.m.OriginalCompanyName = campaignData.getName();
		this.m.OriginalCompanyBanner = campaignData.getBanner();

		this.m.TextVariant = ::Math.rand(1, 4);
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"bro",
			this.m.Bro.getNameOnly()
		]);
		_vars.push([
			"brocompanyname",
			this.m.OriginalCompanyName
		]);
	}

	function onClear()
	{
		this.m.Bro = null;
		this.m.Demand = null;
		this.m.OriginalCompanyName = null;
		this.m.OriginalCompanyBanner = null;
		this.m.TextVariant = null;
	}
});
