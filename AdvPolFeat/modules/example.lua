-- EXAMPLE
-- Author: Your Name
example = {
	_id = 'EXAMPLE', -- DONT CHANGE THIS PARAMETER!!!
	_dlu = 'https://google.com', -- AND THIS PARAMETER DONT CHANGE!!!
	_author = 'Fuexie',
	_ver = '1.0',
	temp = {
		init_res = false -- Результат инициализации, используется в основной функции модуля
	}
}
--[[
-- Немного про параметры модуля.
-- _id - Уникальный идентификатор модуля, нельзя иметь повторяющиеся
-- _dlu - ссылка на скачивание (если модуль не официальный, то 'google.com')
-- _author - автор модуля. Можно ставить nil. Пока нигде не используется
-- _ver - версия модуля.
--
-- параметры _id и _dlu не рекомендуется трогать, поскольку они сверяются с параметрами
-- модулей в вайтлисте. И если вы их измените, проверка может сказать, что модуль не в вайтлисте
-- ]]

local function registerCommands() -- Регистрация всех команд
	for k, v in pairs(example._COMMANDS) do
		sampRegisterChatCommand(k, v[1])
	end
end

function example.init(it) -- Функция инициализации. К примеру подгрузка файлов и т.п. В этом примере просто привоение переменной и регистрация команд. Выполняется один раз сама по себе. Можно вызвать, чтоб провести ещё раз инициализацию
	if it ~= nil then -- если аргумент функции что-то содержит, или просто не равен nil.
		example.subdata = it -- it - аргумент функции, subdata - некоторая переменная
		example.temp.init_res = true -- обозначаем, что модуль прошел инициализацию.
		registerCommands()
		--print('test')
		return true
	else
		return nil, 'before starting example module, execute initialization (module.init(self)) or set arg main (self)' -- возвращает nil, и ошибку.
	end
end

function example.main(it)
--[[
-- основная функция модуля.
-- в отличие от функции инициализации, без этой модуль не будет работать.
-- Пока не реализовано, но планируется что в main будут передаваться следующие аргументы:
-- apf_ver - версия APF, через которую выполняется модуль,
-- ml_ver - версия moonloader,
--
--
--]]

	if example.temp.init_res then -- проверка на прохождение инициализации. если true то смотрим далее
		return function () -- анонимная функция, которая как раз и выполняется после прохождения инициализации.
		-- Предусмотрено только такой метод. Не будет анонимной функции - модуль, и что более вероятно весь APF работать не будет.
			if wasKeyPressed(0x2D) then -- Проверка на нажатие клавиши INSERT
				print(example.subdata) -- печатает в чат переменную, которая была объявлена при инициализации
			end
		end
	else -- если модуль не прошёл инициализацию
		local initresult, err = example.init(it) -- так как функция init возвращает два значения: nil и ошибка или просто true
		-- мы двум переменным присваиваем возвращаемые значения функции инициализации

		if not initresult then -- если по какой-то причине инициализация не проходит
			return nil, err -- возвращает nil и ошибку
		else
			return example.main(it) -- если инициализация прошла, функция возвращает саму же себя, и так как инициализация прошла успешно, то
			-- переменная example.init_res будет равна true, из-за чего функция main в этот раз пойдёт по другому сценарию
		end
	end
end

local prfx = "apf/example" -- префикс команд модуля
example._COMMANDS = {
--[[
-- _COMMANDS - таблица с командами модуля.
-- Естественно для работы необязательно все это пихать в модуль, достаточно только функции main()
-- Но если ваш модуль подразумевает использование команд, то данная структура, как мне кажется подходит наилучшим образом
-- prfx = "apf/example" - префикс команд модуля, как и выше написано. Он используется в sampRegisterChatCommand
-- Если вы обратите внимание на функцию registerCommands() вы поймете как это работает.
-- Если короче и проще, то - в качестве ключа каждой команды используйте префикс + продолжение команды
--]]
	[prfx] = { -- prfx = apf/example, а значит команда будет /apf/example
		[1] = function() -- 1 ячейка таблицы команды занимает функцию, которую исполняет компанда
			slm('* Full list of commands: ', 0xD4D4D4)
			for k, v in pairs(example._COMMANDS) do
				slm(v[2], 0xD4D4D4)
			end
		end,
		[2] = 'Use /'..prfx..': to get a full list of commands.' -- 2 же ячейка таблицы используется как подсказка, при написании команды
		-- которая выводит полный список команд модуля либо в качестве подсказки при несоответствии аргументов команды (см. пример ниже)
	},
	[prfx..'/test'] = { -- команда будет /apf/example/test
		[1] = function(arg)
			if arg == nil or #arg == 0 then
				slm(example._COMMANDS[prfx..'/test'][2], 0xD4D4D4) -- вывод подсказки
			else
				slm('* You determine command-argument next: '..arg, 0xD4D4D4) -- тут уже выполняет свою функцию команда
				-- А ну и да, май инглиш из греатест.
			end
		end,
		[2] = "Use /apf/example/test <name>: for print name"
	}
}

return example
