package timer

import (
	"time"

	"github.com/charmbracelet/bubbles/timer"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

const criticalThreshold = 30 * time.Second

var (
	titleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("15")).
			Background(lipgloss.Color("63")).
			Padding(0, 2)

	normalStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("15"))

	criticalStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("196")).
			Bold(true)
)

type Model struct {
	timer    timer.Model
	duration time.Duration
}

func NewModel(duration time.Duration) Model {
	return Model{
		timer:    timer.NewWithInterval(duration, time.Second),
		duration: duration,
	}
}

func (m Model) Init() tea.Cmd {
	return m.timer.Init()
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case timer.TickMsg:
		var cmd tea.Cmd
		m.timer, cmd = m.timer.Update(msg)
		return m, cmd

	case timer.TimeoutMsg:
		return m, tea.Quit

	case tea.KeyMsg:
		// Ignore all key input — terminal is locked during break
		return m, nil
	}

	return m, nil
}

func (m Model) View() string {
	remaining := m.timer.Timeout

	title := titleStyle.Render("TAKE A BREAK")
	bigTime := renderBigTime(remaining)

	style := normalStyle
	if remaining <= criticalThreshold {
		style = criticalStyle
	}

	content := lipgloss.JoinVertical(
		lipgloss.Center,
		title,
		"",
		style.Render(bigTime),
	)

	return lipgloss.Place(
		lipgloss.Width(content)+4,
		lipgloss.Height(content)+2,
		lipgloss.Center,
		lipgloss.Center,
		content,
	)
}

func Run(duration time.Duration) error {
	p := tea.NewProgram(
		NewModel(duration),
		tea.WithAltScreen(),
	)

	_, err := p.Run()
	return err
}
