# lua-selections (v2)

**`lua-selections`** is a modular Lua terminal UI toolkit built on `luv` (libuv). It gives you arrow-key driven menus, text prompts, ANSI colors, and a message system with pinning/editing. Basically: cursed but usable TUIs.

---

## 🔧 Features

* Arrow key navigation (↑ ↓ ← →)
* Y-only or full X/Y grid-style menus
* Multi-select prompts with `[ SUBMIT > ]`
* Text input prompts
* Colored output with ANSI escapes
* Message objects with `pin`, `unpin`, `update`, `delete`
* Warning / error helpers
* Clean screen refresh system (no `print()`!!)

---

## 🚀 Getting Started

```lua
local selections = require("init")  -- from this repo
```

> ✅ Requires Lua + `luv` (libuv bindings)

---

## 📋 Example Usage

### 🗣️ Text Input Prompt

```lua
selections.createPrompt("What's your name?", function(name)
    selections.output:write("Hello, " .. name)
end)
```

### 🔢 Y-Only Menu Prompt

```lua
selections.createPrompt("Pick a number:", {
    {"One"},
    {"Two"},
    {"Three"}
}, function(choice, row)
    selections.output:write("You picked: " .. choice.value)
end)
```

### 🎯 X/Y Grid Prompt

```lua
selections.createPrompt("Category Example", {
    {"A1", "A2", "A3"},
    {"B1", "B2", "B3"},
    {"C1", "C2", "C3"}
}, function(choice, row)
    selections.output:write("You chose: " .. choice.value)
end)
```

### 🧩 Multi-Select Prompt

```lua
selections.createPrompt("Select toppings:", {
    {"Cheese", "Pepperoni", "Mushrooms"},
    {"Olives", "Pineapple", "Onions"}
}, function(choices)
    for topping in pairs(choices) do
        selections.output:write("✓ " .. topping)
    end
end, 3) -- allow up to 3
```

---

## 🎨 Colors

```lua
local str = selections.string.color("This is red", "red")
selections.output:write(str)
```

Available colors:

```
black, red, green, yellow, blue,
magenta, cyan, white,
pink, orange, brightBlue
```

---

## 🧠 Prompt Return Values

* **Single-select:** callback receives `(option, rowIndex)`
* **Multi-select:** callback receives `(tableOfChoices, nil)`
* **Text input:** callback receives `(string)`

---

## ⌨️ Keybindings

| Key     | Action           |
| ------- | ---------------- |
| ↑ ↓ ← → | Navigate         |
| Enter   | Confirm / toggle |
| Ctrl+C  | Exit prompt      |
| 1–9     | Jump to row      |

---

## 📦 Output System

```lua
local msg = selections.output:write("Basic message")

msg:update("Edited message")
msg:pin()
msg:unpin()
msg:delete()

selections.output:warn("Something might be off")
selections.output:error("Something broke")
```

---

## 🧼 Clear Screen

```lua
selections.output:clear()
```

---

## 📝 License

GNU GENERAL PUBLIC LICENSE

---

## 🤝 Contributing

PRs welcome. Add stuff like mouse support, emoji menus, or animations!

---

Want me to also include a **section diagramming the modules** (like `init`, `output`, `message`, `string`, `number`) so people know how the pieces fit together, or keep it user-facing only?
