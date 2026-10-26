from houdini.handlers import XTPacket
import asyncio
import random
import difflib
from houdini.plugins import IPlugin
from houdini import commands
from houdini import permissions
from houdini.data.penguin import Penguin
from houdini.data.room import Room
from houdini.data.moderator import Ban
from houdini.handlers.play.moderation import moderator_ban, moderator_kick

class Essentials(IPlugin):
    author = "Solero"
    description = "Essentials plugin"
    version = "1.0.0"

    def __init__(self, server):
        super().__init__(server)
        self.items_by_name = self.igloos_by_name = self.furniture_by_name = self.puffles_by_name = None

    async def ready(self):
        perms = [
            'essentials.jr', 'essentials.ai', 'essentials.ac', 'essentials.send_ai', 'essentials.ninja',
            'essentials.puffle', 'essentials.tp', 'essentials.ban', 'essentials.summon', 'essentials.kick',
            'essentials.stamps', 'essentials.mail', 'essentials.medals', 'essentials.af', 'essentials_aig',
            'essentials.all', 'essentials.nickname'
        ]

        from asyncpg.exceptions import UniqueViolationError

        for perm in perms:
            try:
                await self.server.permissions.register(perm)
            except UniqueViolationError:
                pass

        self.items_by_name = {item.name: item for item in self.server.items.values()}
        self.igloos_by_name = {igloo.name: igloo for igloo in self.server.igloos.values()}
        self.furniture_by_name = {furniture.name: furniture for furniture in self.server.furniture.values()}
        self.puffles_by_name = {puffle.name: puffle for puffle in self.server.puffles.values()}

    async def get_penguin(self, username: str):
        penguin_id = await Penguin.select('id').where(Penguin.username == username.lower()).gino.first()
        if penguin_id:
            penguin_id = int(penguin_id[0])
            return self.server.penguins_by_id.get(penguin_id)
        return None
    @commands.command('room', alias=['jr'])
    @permissions.has_or_moderator('essentials.jr')
    async def join_room(self, p, room_id: int = None, version_id: int = None, file_id: int = None):
        def log(data: str):
            asyncio.create_task(p.send_xt('mm', f"Joining {data} for room {room_id}", p.id))
        room: Room = self.server.rooms.get(room_id)
        if not room:
            return await p.send_xt('mm', f"No room exists with id {room_id}", p.id)
        if version_id is None:
            log("base room")
            return await p.join_room(room)
        room_version = room.versions.get(version_id)
        if not room_version:
            valid_versions = ", ".join(map(str, room.versions.keys()))
            return await p.send_xt('mm', f"Version {version_id} is not available for room {room_id} (valid versions: {valid_versions})", p.id)
        if room.name in ("party", "partysolo"):
            if file_id is None:
                return await p.send_xt('mm', "A valid file id must be provided for 'party' and 'partysolo' rooms", p.id)
            party_room = room_version.files.get(file_id)
            if not party_room:
                return await p.send_xt('mm', f"File {file_id} does not exist in version {version_id} ({room_version.version_name}) for room {room_id} ('{room.name}')", p.id)
            log(f"file {file_id} (version {version_id})")
            return await p.join_room(party_room)
        log(f"version {version_id}")
        return await p.join_room(room_version)

    @commands.command('ai')
    @permissions.has_or_moderator('essentials.ai')
    async def add_item(self, p, *query: str):
        await self.add_item_to_penguin(p, ' '.join(query))

    async def add_item_to_penguin(self, p, query: str):
        try:
            item = self.server.items[int(query)] if query.isdigit() else self.items_by_name[difflib.get_close_matches(query, self.items_by_name.keys(), n=1)[0]]
            await p.add_inventory(item, cost=0)
            return item
        except (IndexError, KeyError):
            await p.send_xt('mm', 'Item does not exist', p.id)
            return None

    @commands.command('send_ai')
    @permissions.has_or_moderator('essentials.send_ai')
    async def send_ai(self, p, username, item_string):
        if (item := await self.add_item_to_penguin(p, item_string.lower())):
            if penguin := await self.get_penguin(username):
                await penguin.add_inventory(item, cost=0)
                await penguin.send_xt('mm', f"You've received {item.name} from {p.username}", penguin.id)

    @commands.command('ac')
    @permissions.has_or_moderator('essentials.ac')
    async def add_coins(self, p, amount: int = 100):
        await p.add_coins(amount, stay=True)

    @commands.command('tp')
    @permissions.has_or_moderator('essentials.tp')
    async def tp(self, p, username):
        if penguin := await self.get_penguin(username):
            await p.join_room(penguin.room)
        else:
            await p.send_xt('mm', 'Player is not Online', p.id)

    @commands.command('summon')
    @permissions.has_or_moderator('essentials.summon')
    async def summon(self, p, username):
        if penguin := await self.get_penguin(username):
            await penguin.join_room(p.room)
        else:
            await p.send_xt('mm', 'Player is not Online', p.id)

    @commands.command('ban')
    @permissions.has_or_moderator('essentials.ban')
    async def ban_penguin(self, p, player: str, message: str, duration: int = 24):
        if penguin := await self.get_penguin(player):
            if duration == 0:
                await Penguin.update.values(permaban=True).where(Penguin.username == player).gino.status()
            else:
                await moderator_ban(p, penguin.id, hours=duration, comment=message)
            await penguin.close()
        else:
            await p.send_xt('mm', 'Player is not Valid', p.id)

    @commands.command('kick')
    @permissions.has_or_moderator('essentials.kick')
    async def kick_penguin(self, p, player: str):
        if penguin := await self.get_penguin(player):
            await moderator_kick(p, penguin.id)
        else:
            await p.send_xt('mm', 'Player is not Valid', p.id)

    async def add_item_by_name(self, p, query: str, collection, collection_by_name):
        try:
            item = collection[int(query)] if query.isdigit() else collection_by_name[difflib.get_close_matches(query, collection_by_name.keys(), n=1)[0]]
            return item
        except (IndexError, KeyError):
            await p.send_xt('mm', 'Item does not exist', p.id)
            return None

    @commands.command('ag')
    @permissions.has_or_moderator('essentials_aig')
    async def add_igloo(self, p, *igloo_query: str):
        igloo = await self.add_item_by_name(p, ' '.join(igloo_query), self.server.igloos, self.igloos_by_name)
        if igloo:
            await p.add_igloo(igloo, cost=0)

    @commands.command('af')
    @permissions.has_or_moderator('essentials.af')
    async def add_furnishings(self, p, Query: str, Units: int):
        try:
            Furniture = await self.add_item_by_name(p, Query, self.server.furniture, self.furniture_by_name)
            if Furniture:
                for _ in range(Units):
                    await p.add_furniture(Furniture, cost=0)
        except (IndexError, KeyError):
            await p.send_xt('mm', 'Furniture is Invalid', p.id)

    @commands.command('pay')
    async def pay_coins(self, p, username, amount: int):
        if amount <= 0:
            return await p.send_xt('mm', 'Please enter a valid number', p.id)
        if p.username == username:
            return await p.send_xt("mm", "You can't transfer to yourself!", p.id)
        count = await p.coins
        penguin = await self.get_penguin(username)
        if penguin and count >= amount:
            await p.update(coins=count - amount).apply()
            await penguin.update(coins=penguin.coins + amount).apply()
            await p.send_xt('cdu', p.coins, p.coins)
            await penguin.send_xt('cdu', penguin.coins, penguin.coins)
            await p.send_xt('mm', f'Successfully transferred {amount} coins to {username}', p.id)
            await penguin.send_xt('mm', f"You've received {amount} from {p.username}", penguin.id)
        else:
            await p.send_xt('mm', 'Player is not Online or insufficient coins', p.id)

    @commands.command('stamps')
    @permissions.has_or_moderator('essentials.stamps')
    async def stamps(self, p):
        await asyncio.gather(*(p.add_stamp(stamp) for stamp in self.server.stamps.values()))

    @commands.command('mail')
    @permissions.has_or_moderator('essentials.mail')
    async def postcards(self, p):
        await asyncio.gather(*(p.add_inbox(postcard) for postcard in self.server.postcards.values()))

    @commands.command('medals')
    @permissions.has_or_moderator('essentials.medals')
    async def add_medals(self, p, career_medals_in: int = 100, agent_medals_in: int = 100):
        await p.update(
            career_medals=p.career_medals + career_medals_in,
            agent_medals=p.agent_medals + agent_medals_in
        ).apply()
        await p.send_xt('epfgr', career_medals_in, agent_medals_in)

    @commands.command('ninja')
    @permissions.has_or_moderator('essentials.ninja')
    async def become_ninja(self, p):
        ninja_belts = list(range(4025, 4034))
        ids = ninja_belts + [4034, 104, 5040] + [6025, 4120, 2013, 1086] + [6026, 4121, 2025, 1087] + [6163, 4834, 2119, 1581]
        if Shadow := False:
            ids.extend([6077, 4380, 2033, 1271])
        for card in self.server.cards.values():
            await p.add_card(card)
        await p.update(ninja_rank=10, ninja_progress=0, fire_ninja_rank=4, water_ninja_rank=4, snow_ninja_rank=24).apply()
        await asyncio.gather(*(p.add_inventory(self.server.items[item_id], cost=0) for item_id in ids))

    @commands.command('ap')
    @permissions.has_or_moderator('essentials.puffle')
    async def add_puffles(self, p, query: str, penguin: str = None):
        penguin = await self.get_penguin(penguin) if penguin else p
        if not penguin or len(p.puffles) >= 75:
            return await p.send_xt('mm', 'Cannot adopt more puffles', p.id)
        puffle = await self.add_item_by_name(p, query, self.server.puffles, self.puffles_by_name)
        if puffle:
            if puffle.id < 10:
                await penguin.update(coins=penguin.coins + 400).apply()
            elif puffle.id == 10:
                penguin.rainbow_adoptability = True
            await penguin.send_xt('ap_command', puffle.name.lower() if puffle.id < 12 else puffle.id)

    @commands.command('all')
    @permissions.has_or_moderator('essentials.all')
    async def add_all(self, p):
        for item in self.server.items.values():
            await p.add_inventory(item, cost=0)

        for stamp in self.server.stamps.values():
            await p.add_stamp(stamp)

        for igloo in self.server.igloos.values():
            await p.add_igloo(igloo, cost=0)

        for furniture in self.server.furniture.values():
            await p.add_furniture(furniture, cost=0)

        for location in self.server.locations.values():
            await p.add_location(location, cost=0)

        for flooring in self.server.flooring.values():
            await p.add_flooring(flooring, cost=0)

        for card in self.server.cards.values():
            await p.add_card(card)

    @commands.command('nickname', alias=['nick'])
    @permissions.has_or_moderator('essentials.nickname')
    async def nickname(self, p, *, nickname: str):
        await p.update(nickname=nickname).apply()
        room = self.server.rooms.get(p.room.id)
        if room:
            await p.join_room(room)
